#!/usr/bin/env python3
"""Small local Piper TTS server for Luna Math Adventure development.

The Flutter app calls this server from Chrome. Generated WAV files live in a
temporary directory and are removed per game session.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
import tempfile
import wave
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse

from piper import PiperVoice
from piper.config import SynthesisConfig


DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8765
DEFAULT_ES_VOICE_ID = "es_ES-sharvard-medium"
DEFAULT_CA_VOICE_ID = "ca_ES-upc_ona-medium"


def _safe_segment(value: str) -> str:
    cleaned = "".join(
        char if char.isalnum() or char in ("-", "_") else "_" for char in value
    ).strip("_")
    return cleaned or "default"


def _read_json(handler: BaseHTTPRequestHandler) -> dict:
    length = int(handler.headers.get("Content-Length", "0"))
    if length <= 0:
        return {}

    payload = handler.rfile.read(length).decode("utf-8")
    return json.loads(payload)


def _language_key(language_code: str) -> str:
    return "ca" if language_code.lower().startswith("ca") else "es"


def _language_key_for_voice(voice_id: str) -> str:
    return "ca" if voice_id.startswith("ca_") else "es"


def _config_path_for(model_path: Path) -> Path | None:
    config_path = model_path.with_suffix(".onnx.json")
    return config_path if config_path.exists() else None


class PiperBackend:
    def __init__(self, *, cache_dir: Path, piper_bin: str, models: dict[str, Path]):
        self.cache_dir = cache_dir
        self.models = models
        self._voices: dict[str, PiperVoice] = {}

    def synthesize(
        self,
        *,
        session_id: str,
        clip_id: str,
        text: str,
        language_code: str,
        voice_id: str | None,
        speaker_id: int | None,
    ) -> tuple[str, str]:
        resolved_voice_id = self._voice_id_for(
            language_code=language_code,
            voice_id=voice_id,
        )
        if not resolved_voice_id:
            raise RuntimeError(
                f"No Piper model configured for language {language_code!r}."
            )

        session_dir = self.cache_dir / _safe_segment(session_id)
        session_dir.mkdir(parents=True, exist_ok=True)

        digest = hashlib.sha1(
            (
                f"{language_code}\0{resolved_voice_id}\0"
                f"{speaker_id if speaker_id is not None else ''}\0"
                f"{clip_id}\0{text}"
            ).encode("utf-8")
        ).hexdigest()
        output_path = session_dir / f"{digest}.wav"
        if output_path.exists():
            return self._url_for(session_id, output_path.name), resolved_voice_id

        voice = self._voice_for(resolved_voice_id)
        syn_config = SynthesisConfig(speaker_id=speaker_id)
        wrote_audio = False
        with wave.open(str(output_path), "wb") as wav_file:
            for chunk in voice.synthesize(text, syn_config=syn_config):
                if not wrote_audio:
                    wav_file.setnchannels(chunk.sample_channels)
                    wav_file.setsampwidth(chunk.sample_width)
                    wav_file.setframerate(chunk.sample_rate)
                    wrote_audio = True

                wav_file.writeframes(chunk.audio_int16_bytes)

        if not wrote_audio:
            output_path.unlink(missing_ok=True)
            raise RuntimeError("Piper did not generate audio.")

        return self._url_for(session_id, output_path.name), resolved_voice_id

    def delete_session(self, session_id: str) -> None:
        shutil.rmtree(
            self.cache_dir / _safe_segment(session_id),
            ignore_errors=True,
        )

    def audio_path(self, session_id: str, filename: str) -> Path | None:
        safe_session = _safe_segment(session_id)
        safe_filename = Path(filename).name
        path = self.cache_dir / safe_session / safe_filename
        if not path.exists() or path.suffix.lower() != ".wav":
            return None

        return path

    def _url_for(self, session_id: str, filename: str) -> str:
        return f"/audio/{_safe_segment(session_id)}/{filename}"

    def _voice_id_for(self, *, language_code: str, voice_id: str | None) -> str | None:
        if voice_id and voice_id in self.models:
            return voice_id

        language_key = _language_key(language_code)
        preferred_id = (
            DEFAULT_CA_VOICE_ID if language_key == "ca" else DEFAULT_ES_VOICE_ID
        )
        if preferred_id in self.models:
            return preferred_id

        for candidate_id in sorted(self.models):
            if _language_key_for_voice(candidate_id) == language_key:
                return candidate_id

        if language_key == "ca" and DEFAULT_ES_VOICE_ID in self.models:
            return DEFAULT_ES_VOICE_ID

        return next(iter(sorted(self.models)), None)

    def _voice_for(self, voice_id: str) -> PiperVoice:
        if voice_id in self._voices:
            return self._voices[voice_id]

        model_path = self.models[voice_id]
        config_path = _config_path_for(model_path)
        voice = PiperVoice.load(
            str(model_path),
            config_path=str(config_path) if config_path else None,
        )
        self._voices[voice_id] = voice
        return voice


def make_handler(backend: PiperBackend, base_url: str):
    class Handler(BaseHTTPRequestHandler):
        def do_OPTIONS(self) -> None:
            self._send_empty(HTTPStatus.NO_CONTENT)

        def do_GET(self) -> None:
            parsed = urlparse(self.path)
            parts = [unquote(part) for part in parsed.path.split("/") if part]
            if len(parts) != 3 or parts[0] != "audio":
                self._send_json({"error": "Not found"}, HTTPStatus.NOT_FOUND)
                return

            audio_path = backend.audio_path(parts[1], parts[2])
            if audio_path is None:
                self._send_json({"error": "Audio not found"}, HTTPStatus.NOT_FOUND)
                return

            data = audio_path.read_bytes()
            self.send_response(HTTPStatus.OK)
            self._send_cors_headers()
            self.send_header("Content-Type", "audio/wav")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_POST(self) -> None:
            parsed = urlparse(self.path)
            if parsed.path == "/api/tts/prepare":
                self._prepare()
                return

            if parsed.path == "/api/tts/synthesize":
                self._synthesize_one()
                return

            self._send_json({"error": "Not found"}, HTTPStatus.NOT_FOUND)

        def do_DELETE(self) -> None:
            parsed = urlparse(self.path)
            prefix = "/api/tts/session/"
            if not parsed.path.startswith(prefix):
                self._send_json({"error": "Not found"}, HTTPStatus.NOT_FOUND)
                return

            session_id = unquote(parsed.path[len(prefix) :])
            backend.delete_session(session_id)
            self._send_json({"ok": True})

        def log_message(self, format: str, *args) -> None:
            sys.stdout.write("[piper-tts] " + (format % args) + "\n")

        def _prepare(self) -> None:
            try:
                payload = _read_json(self)
                session_id = str(payload.get("sessionId", "default"))
                language_code = str(payload.get("languageCode", "es-ES"))
                voice_id = str(payload.get("voiceId", "")).strip() or None
                speaker_id = _optional_int(payload.get("speakerId"))
                clips = payload.get("clips", [])
                if not isinstance(clips, list):
                    self._send_json(
                        {"error": "clips must be a list"},
                        HTTPStatus.BAD_REQUEST,
                    )
                    return

                prepared = []
                for clip in clips:
                    if not isinstance(clip, dict):
                        continue

                    clip_id = str(clip.get("id", "clip"))
                    text = str(clip.get("text", "")).strip()
                    if not text:
                        continue

                    url, resolved_voice_id = backend.synthesize(
                        session_id=session_id,
                        clip_id=clip_id,
                        text=text,
                        language_code=language_code,
                        voice_id=voice_id,
                        speaker_id=speaker_id,
                    )
                    prepared.append(
                        {
                            "id": clip_id,
                            "text": text,
                            "voiceId": resolved_voice_id,
                            "speakerId": speaker_id,
                            "url": base_url + url,
                        }
                    )

                self._send_json({"clips": prepared})
            except Exception as error:
                self._send_json(
                    {"error": str(error)},
                    HTTPStatus.INTERNAL_SERVER_ERROR,
                )

        def _synthesize_one(self) -> None:
            try:
                payload = _read_json(self)
                session_id = str(payload.get("sessionId", "default"))
                language_code = str(payload.get("languageCode", "es-ES"))
                voice_id = str(payload.get("voiceId", "")).strip() or None
                speaker_id = _optional_int(payload.get("speakerId"))
                clip_id = str(payload.get("id", "clip"))
                text = str(payload.get("text", "")).strip()
                if not text:
                    self._send_json(
                        {"error": "text is required"},
                        HTTPStatus.BAD_REQUEST,
                    )
                    return

                url, resolved_voice_id = backend.synthesize(
                    session_id=session_id,
                    clip_id=clip_id,
                    text=text,
                    language_code=language_code,
                    voice_id=voice_id,
                    speaker_id=speaker_id,
                )
                self._send_json(
                    {
                        "id": clip_id,
                        "text": text,
                        "voiceId": resolved_voice_id,
                        "speakerId": speaker_id,
                        "url": base_url + url,
                    }
                )
            except Exception as error:
                self._send_json(
                    {"error": str(error)},
                    HTTPStatus.INTERNAL_SERVER_ERROR,
                )

        def _send_empty(self, status: HTTPStatus) -> None:
            self.send_response(status)
            self._send_cors_headers()
            self.end_headers()

        def _send_json(self, payload: dict, status: HTTPStatus = HTTPStatus.OK) -> None:
            data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def _send_cors_headers(self) -> None:
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header(
                "Access-Control-Allow-Methods",
                "GET, POST, DELETE, OPTIONS",
            )
            self.send_header("Access-Control-Allow-Headers", "Content-Type")

    return Handler


def _optional_int(value: object) -> int | None:
    if value is None or value == "":
        return None

    return int(value)


def _add_voice(models: dict[str, Path], voice_id: str, model_path: str | None) -> None:
    if not model_path:
        return

    models[voice_id] = Path(model_path)


def _parse_voice_arg(value: str) -> tuple[str, str]:
    if "=" in value:
        voice_id, model_path = value.split("=", 1)
    else:
        model_path = value
        voice_id = Path(value).stem

    voice_id = voice_id.strip()
    model_path = model_path.strip()
    if not voice_id or not model_path:
        raise argparse.ArgumentTypeError(
            "--voice must be formatted as voice_id=path or path"
        )

    return voice_id, model_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Local Piper TTS server.")
    parser.add_argument("--host", default=DEFAULT_HOST)
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument(
        "--cache-dir",
        default=str(Path(tempfile.gettempdir()) / "luna_math_adventure_tts"),
    )
    parser.add_argument(
        "--piper-bin",
        default=os.environ.get("PIPER_BIN", "piper"),
        help="Deprecated; kept for backwards compatibility.",
    )
    parser.add_argument(
        "--voice",
        action="append",
        type=_parse_voice_arg,
        default=[],
        help="Piper voice model as voice_id=path. May be repeated.",
    )
    parser.add_argument("--es-model", default=os.environ.get("PIPER_ES_MODEL"))
    parser.add_argument("--ca-model", default=os.environ.get("PIPER_CA_MODEL"))
    args = parser.parse_args()

    models: dict[str, Path] = {}
    for voice_id, model_path in args.voice:
        _add_voice(models, voice_id, model_path)

    _add_voice(models, DEFAULT_ES_VOICE_ID, args.es_model)
    _add_voice(models, DEFAULT_CA_VOICE_ID, args.ca_model)

    if not models:
        print(
            "Missing Piper models. Use --voice, --es-model, or PIPER_ES_MODEL.",
            file=sys.stderr,
        )
        return 2

    cache_dir = Path(args.cache_dir)
    cache_dir.mkdir(parents=True, exist_ok=True)

    backend = PiperBackend(
        cache_dir=cache_dir,
        piper_bin=args.piper_bin,
        models=models,
    )
    base_url = f"http://{args.host}:{args.port}"
    server = ThreadingHTTPServer(
        (args.host, args.port),
        make_handler(backend, base_url),
    )
    print(f"Piper TTS server listening at {base_url}")
    print(f"Temporary audio cache: {cache_dir}")
    print("Available voices:")
    for voice_id, model_path in sorted(models.items()):
        print(f"  {voice_id}: {model_path}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping Piper TTS server.")
    finally:
        server.server_close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
