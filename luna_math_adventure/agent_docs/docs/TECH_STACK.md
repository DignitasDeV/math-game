# Tech Stack

## Framework

- Flutter

## Lenguaje

- Dart

## Estado

- `flutter_riverpod`

Uso:

- Providers para servicios.
- Notifier/StateNotifier para controladores.
- Separación clara entre estado de UI y dominio.

## Navegación

- `go_router`

Rutas principales:

```text
/splash
/onboarding/language
/onboarding/child-name
/onboarding/unicorn-variant
/onboarding/unicorn-name
/home
/map
/game/:levelId
/practice
/help
/rewards
/settings
```

## TTS

- `flutter_tts`

Uso:

- Leer enunciados.
- Leer pistas.
- Leer ayuda matemática.
- Cambiar idioma según `AppLanguage`.

Idiomas:

- `es-ES`
- `ca-ES`

## Audio

- `just_audio`

Uso:

- Música de fondo.
- SFX de botones.
- SFX de acierto.
- SFX de error suave.
- SFX de recompensa.
- Ducking cuando habla el TTS.

## Persistencia MVP

- `shared_preferences`

Uso:

- Perfil.
- Idioma.
- Progreso.
- Último nivel.
- Ajustes de audio.

## Persistencia futura

Evaluar:

- Hive.
- Isar.
- SQLite.

No usar backend en MVP.

## Animaciones

- `lottie`
- `flutter_animate`

Uso de Lottie:

- Confeti.
- Sparkles.
- Recompensas.
- Celebraciones.

Uso de flutter_animate:

- Bounce.
- Fade.
- Scale.
- Shake suave.
- Aparición de respuestas.
- Microinteracciones.

## Iconos

- Material Icons.
- `material_symbols_icons`.
- `font_awesome_flutter`.

Uso:

- Altavoz.
- Ajustes.
- Home.
- Repetir.
- Continuar.
- Pista.
- Candado.
- Estrella.
- Corazón.
- Trofeo.

## SVG

- `flutter_svg`

Uso:

- Iconos SVG externos.
- Assets vectoriales de UI.

## Assets

Formatos recomendados:

- `.webp` para imágenes generadas.
- `.png` si se necesita transparencia especial.
- `.svg` para iconos.
- `.json` para Lottie.
- `.wav` para SFX cortos.
- `.mp3` para musica y audios largos.
- `.json` para datos de niveles, ayuda, traducciones y recompensas.

## Dependencias iniciales esperadas

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod:
  go_router:
  flutter_tts:
  just_audio:
  shared_preferences:
  flutter_svg:
  lottie:
  flutter_animate:
  font_awesome_flutter:
  material_symbols_icons:
```

Usar versiones concretas al crear el proyecto.
