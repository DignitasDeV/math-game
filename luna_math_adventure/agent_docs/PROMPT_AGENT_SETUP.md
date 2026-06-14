# Prompt para agente de VSCode: setup inicial del proyecto

Actúa como desarrollador senior Flutter/Dart y prepara la puesta a punto inicial de un proyecto llamado `luna_math_adventure`.

## Contexto del proyecto

Estamos desarrollando un juego educativo infantil de matemáticas para una niña de 6 años. El juego debe ser visual, mágico, dinámico, bilingüe y no encorsetado. La temática gira alrededor de unicornios/unicornias, corazones, estrellas, arcoíris, mundos mágicos y recompensas.

## Objetivo de la app

Crear una app Flutter para practicar conteo, sumas y restas de forma progresiva, desde operaciones muy sencillas hasta sumas/restas con números hasta 20, incluyendo ejercicios avanzados como `12 + 17`, pero siempre con ayuda visual, pistas y lectura en voz alta.

## Decisiones principales

- Framework: Flutter.
- Lenguaje: Dart.
- Estado: flutter_riverpod.
- Navegación: go_router.
- TTS local: flutter_tts.
- Audio local: just_audio.
- Animaciones Lottie: lottie.
- Microanimaciones: flutter_animate.
- Iconos: Material Icons, material_symbols_icons y font_awesome_flutter.
- SVG: flutter_svg.
- Persistencia MVP: shared_preferences.
- Persistencia futura: Hive o base local más robusta.
- Backend: no en el MVP.
- Idiomas iniciales: español (`es-ES`) y catalán (`ca-ES`).
- IA: se usará para generar assets de identidad visual, como personajes, fondos, mundos y recompensas especiales.
- Librerías/packs: se usarán para iconos funcionales, UI genérica, estrellas, corazones simples, confeti, sparkle y animaciones reutilizables.

## Instrucciones de puesta a punto

1. Crear o preparar el proyecto Flutter.
2. Configurar `pubspec.yaml` con las dependencias necesarias.
3. Crear la estructura de carpetas propuesta.
4. Crear archivos base de tema visual, rutas, providers y servicios.
5. Crear pantallas placeholder:
   - SplashScreen
   - LanguageSelectionScreen
   - ChildNameScreen
   - UnicornVariantScreen
   - UnicornNameScreen
   - HomeScreen
   - MapScreen
   - GameScreen
   - PracticeModeScreen
   - HelpCenterScreen
   - RewardsScreen
   - SettingsScreen
6. Crear servicios abstractos:
   - SpeechService
   - AudioService
   - ProgressRepository
   - ExerciseGenerator
   - HintGenerator
   - OptionGenerator
   - RewardService
   - LocalizationRepository
7. Crear modelos base:
   - PlayerProfile
   - PlayerProgress
   - AppLanguage
   - LocalizedText
   - UnicornVariant
   - World
   - LevelConfig
   - Exercise
   - OperationCandidate
   - ExerciseTemplate
   - VisualItem
   - Reward
8. Crear JSON iniciales en `assets/data/`:
   - levels.json
   - worlds.json
   - visual_items.json
   - rewards.json
   - exercise_templates.json
   - help_topics.json
   - localization.json
9. Crear carpetas de assets vacías con `.gitkeep`.
10. Crear documentación técnica inicial:
   - README.md
   - AGENTS.md
   - docs/ROADMAP.md
   - docs/TECH_STACK.md
   - docs/ARCHITECTURE.md
   - docs/GAME_DESIGN.md
   - docs/EXERCISE_ENGINE.md
   - docs/ASSETS.md
   - docs/AUDIO_TTS.md
   - docs/STYLE_GUIDE.md
   - docs/I18N.md
11. Implementar una primera pantalla de prueba donde:
   - Se muestre un enunciado de suma.
   - Se pueda pulsar un botón de altavoz para leerlo con TTS.
   - Se pueda reproducir un SFX de acierto.
   - Se muestre un botón de respuesta.
12. No implementar todavía lógica avanzada de juego completa. El objetivo inicial es dejar el proyecto bien estructurado y preparado para desarrollar por fases.

## Reglas importantes

- No hardcodear ejercicios fijos como única fuente de contenido.
- Los niveles se definen manualmente por reglas, pero los ejercicios concretos se generan dinámicamente.
- No usar random puro sin control.
- Usar una bolsa de operaciones válidas por nivel, mezclada en cada partida.
- Evitar repeticiones recientes dentro de una sesión.
- Permitir repetir niveles.
- Permitir continuar desde el último nivel jugado.
- Permitir entrar libremente en cualquier nivel desbloqueado.
- Añadir modo práctica libre.
- Separar texto visible y texto hablado.
- Traducir textos visibles y hablados a español y catalán.
- Usar TTS `es-ES` o `ca-ES` según idioma seleccionado.
- No castigar errores: usar feedback amable.
- Preparar personalización de nombre de la niña y nombre/género del unicornio/unicornia.
- Mantener el código modular por features.
- Priorizar MVP simple, extensible y limpio.

## Estructura de carpetas esperada

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
      app_colors.dart
      app_theme.dart
      app_typography.dart
  core/
    utils/
    services/
    widgets/
  features/
    profile/
    localization/
    game/
    map/
    practice/
    help/
    rewards/
    speech/
    audio/
    settings/
    progress/

assets/
  images/
    characters/
    backgrounds/
    items/
    rewards/
    ui/
  animations/
  audio/
    sfx/
    music/
    voice/
  data/
    i18n/
  licenses/

docs/
  ROADMAP.md
  TECH_STACK.md
  ARCHITECTURE.md
  GAME_DESIGN.md
  EXERCISE_ENGINE.md
  ASSETS.md
  AUDIO_TTS.md
  STYLE_GUIDE.md
  I18N.md
```

## Criterio de éxito

El proyecto debe arrancar, tener navegación básica, tema visual inicial, estructura de carpetas, dependencias instaladas, servicios base creados, documentación inicial, onboarding placeholder y una pantalla de prueba de TTS/audio.
