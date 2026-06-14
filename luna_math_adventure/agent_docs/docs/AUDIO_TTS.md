# Audio y TTS

## Objetivo

La app debe poder leer en voz alta enunciados, pistas y ayuda matemática. También debe tener efectos de sonido y música suave.

## Estrategia

- TTS local del dispositivo para textos dinámicos.
- SFX locales para feedback.
- Música local suave para ambiente.
- Frases pregrabadas opcionales más adelante.

## TTS

Usar `flutter_tts`.

Idiomas:

- Español: `es-ES`
- Catalán: `ca-ES`

El idioma depende del perfil del usuario.

## Separar texto visible y texto hablado

No leer siempre el texto visual tal cual.

Ejemplo:

```dart
visibleQuestion: "12 + 17 = ?"
spokenQuestion: "Doce más diecisiete. ¿Cuánto es?"
```

Ejemplo catalán:

```dart
visibleQuestion: "12 + 17 = ?"
spokenQuestion: "Dotze més disset. Quant és?"
```

## SpeechService

Crear abstracción:

```dart
abstract class SpeechService {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> setLanguage(String languageCode);
  Future<void> setRate(double rate);
  Future<void> setPitch(double pitch);
}
```

Implementación inicial:

```text
DeviceTtsSpeechService
```

## AudioService

Crear abstracción:

```dart
abstract class AudioService {
  Future<void> playSfx(String assetPath);
  Future<void> playMusic(String assetPath, {bool loop = true});
  Future<void> stopMusic();
  Future<void> setMusicVolume(double volume);
  Future<void> setSfxVolume(double volume);
  Future<void> duckMusic();
  Future<void> restoreMusic();
}
```

## Prioridad

```text
TTS > SFX > música
```

Cuando habla el TTS:

1. Bajar música.
2. Leer texto.
3. Restaurar música.

## SFX iniciales

```text
assets/audio/sfx/ui/
  tap_01.mp3
  back_01.mp3

assets/audio/sfx/feedback/
  correct_01.mp3
  wrong_soft_01.mp3
  hint_open_01.mp3

assets/audio/sfx/rewards/
  sparkle_01.mp3
  reward_unlock_01.mp3
  level_complete_01.mp3
  sticker_collected_01.mp3
```

## Música inicial

```text
assets/audio/music/
  happy_magic_loop_01.mp3
  calm_rainbow_loop_01.mp3
```

Recomendación:

- música baja.
- volumen inicial 20-30%.
- SFX 70-100%.
- TTS prioridad máxima.

## Fuentes recomendadas

- Kenney audio packs.
- Pixabay music/sound effects.
- Freesound solo con licencia CC0.
- Mixkit si la licencia encaja.
- Sonniss GDC bundle para librería más pro.

## Reglas de licencia

Prioridad:

1. CC0.
2. Royalty-free comercial claro.
3. Evitar NC.
4. Evitar licencias ambiguas.
5. Documentar todo.

## Configuración de usuario

Settings debe permitir:

- activar/desactivar música.
- activar/desactivar SFX.
- activar/desactivar lectura automática.
- cambiar velocidad de voz.
- probar voz.
- cambiar idioma.

## Lectura automática

Recomendación:

- Al entrar en ejercicio: leer enunciado automáticamente si está activado.
- Botón altavoz siempre disponible.
- Pista se lee si se pulsa altavoz o si se configura así.

## Frases pregrabadas futuras

Se pueden añadir para calidez:

```text
assets/audio/voice/es/
  well_done_01.mp3
  try_again_01.mp3
  lets_count_01.mp3

assets/audio/voice/ca/
  molt_be_01.mp3
  torna_ho_a_provar_01.mp3
  comptem_juntes_01.mp3
```

No usar para ejercicios dinámicos.
