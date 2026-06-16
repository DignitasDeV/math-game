# Luna Math Adventure

Juego educativo Flutter para practicar conteo, sumas y restas de forma visual, amable y bilingue.

## Estado actual

### Funcional

- **Onboarding completo**: idioma (ES/CA), nombre del jugador, variante unicornio/unicornia, nombre del personaje.
- **Multi-perfil familiar**: varios perfiles por dispositivo, selector de perfil, perfil activo.
- **Persistencia local**: perfiles y progreso guardados con `shared_preferences`.
- **Home**: tarjetas de colores pastel para Mapa, Jugar, Practica, Premios, Ayuda, Ajustes.
- **Pantalla de juego**: niveles del Bosque de Corazones con TTS, SFX, pistas, feedback y unicornio guia.
- **Mapa inicial**: niveles desbloqueables en modo normal y todos accesibles en modo desarrollo.

### Visual

- **Tema pastel**: paleta completa rosa/lila/azul/menta/dorado con gradientes.
- **Fuente Nunito**: redondeada e infantil via `google_fonts`.
- **Componentes reutilizables**: `AppActionTile`, `AppScreenHeader`, `ResponsiveActionGrid`.
- **Iconos expresivos**: `material_symbols_icons` + emojis nativos.
- **Layout responsive**: `MagicScaffold` con fondos, gradiente y fallbacks de assets.

### Pendiente

- Completar assets finales de objetos, fondos, personajes y recompensas.
- Modo practica libre.
- Centro de ayuda matematica.
- Album/sistema visual de recompensas.
- Mundos posteriores al Bosque de Corazones.

## Stack

Flutter + Dart, Riverpod, go_router, google_fonts, flutter_tts, just_audio, flutter_animate, material_symbols_icons.

## Arranque

```powershell
cd luna_math_adventure
flutter pub get
flutter run -d chrome --web-port 5173
```

## Voz local con Piper

La app puede usar Piper como TTS local para evitar la voz nativa de Windows. Si
el servidor local no esta levantado, cae automaticamente a `flutter_tts`.

Instalacion y arranque basico:

```powershell
cd luna_math_adventure
pip install piper-tts
.\tools\start_piper_tts.ps1
```

La app busca el servidor en:

```text
http://127.0.0.1:8765
```

Se puede cambiar con:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=LUNA_TTS_SERVER_URL=http://127.0.0.1:8765
```

Funcionamiento:

- al entrar en una pantalla de juego, se generan en segundo plano los audios de
  la pregunta y la pista actuales.
- al pulsar el icono de altavoz o la pista, se reproduce el `.wav` generado.
- al salir de la pantalla, la app pide al servidor que borre los audios
  temporales de esa sesion.
- si Piper falla o no esta instalado, se usa la voz del sistema.

Nota para APK: este servidor local con Python/Piper es una herramienta de
desarrollo para Flutter Web/Windows. Una APK no puede depender de este proceso
externo. Para Android mantendremos el fallback nativo y, si queremos la misma
calidad de voz, habra que generar un paquete de audios `.wav` por adelantado o
integrar Piper nativamente en Android.

## Modo desarrollo

En builds debug, la app entra en modo desarrollo por defecto:

- crea un perfil de pruebas si no hay perfil guardado.
- salta el onboarding.
- desbloquea todos los niveles del mapa.
- evita completar niveles previos para probar secciones.

Para probar el flujo real de usuario con onboarding y niveles bloqueados:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=LUNA_PROD_FLOW=true
```

Para resetear datos locales al arrancar:

```powershell
flutter run -d chrome --web-port 5173 --dart-define=LUNA_RESET_ON_START=true
```

Si se cambia `pubspec.yaml` o se anaden assets nuevos, hacer restart completo de Flutter. Hot reload no actualiza bien el asset manifest.

## Assets placeholder

Los `.md` dentro de `assets/` son descripciones/placeholders, no assets cargables por Flutter. La app espera los finales con extension `.webp`, `.wav`, `.mp3` o `.json` segun corresponda.

Mientras falten assets finales, la app usa fallbacks visuales/sonoros para no romper el juego.

## Documentacion

- `luna_math_adventure/AGENTS.md` - reglas para agentes IA.
- `luna_math_adventure/agent_docs/README.md` - vision completa del proyecto.
- `luna_math_adventure/agent_docs/docs/` - documentacion tecnica detallada.
