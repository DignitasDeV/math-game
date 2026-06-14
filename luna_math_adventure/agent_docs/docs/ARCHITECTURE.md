# Arquitectura

## Principio general

Arquitectura modular por features.

Separar:

- UI.
- Estado.
- Dominio.
- Infraestructura.
- Servicios.
- Datos locales.

## Estructura base

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
```

## Estructura interna recomendada por feature

```text
feature_name/
  domain/
    entities/
    enums/
    services/
  application/
    controllers/
    providers/
  infrastructure/
    repositories/
    data_sources/
  presentation/
    screens/
    widgets/
```

No todas las features necesitan todas las carpetas desde el primer día.

## Features

### profile

Responsable de:

- nombre de la niña.
- idioma.
- variante del unicornio/unicornia.
- nombre del personaje.
- onboarding.

Modelos:

- `PlayerProfile`
- `UnicornVariant`

### localization

Responsable de:

- idioma activo.
- textos localizados.
- carga de JSON de traducciones.
- helper de traducción.

Modelos:

- `AppLanguage`
- `LocalizedText`

### game

Responsable de:

- ejercicios.
- generación dinámica.
- sesiones de nivel.
- validación de respuestas.
- pistas.
- opciones de respuesta.

Modelos:

- `Exercise`
- `LevelConfig`
- `OperationCandidate`
- `ExerciseTemplate`
- `VisualItem`

### map

Responsable de:

- mundos.
- niveles.
- niveles bloqueados/desbloqueados.
- navegación libre por niveles desbloqueados.

Modelos:

- `World`
- `WorldProgress`

### practice

Responsable de:

- práctica libre.
- selección de tipo de ejercicio.
- dificultad independiente del mapa.

### help

Responsable de:

- centro de ayuda matemática.
- explicaciones.
- ejemplos visuales.
- TTS de ayuda.

Modelos:

- `HelpTopic`

### rewards

Responsable de:

- recompensas.
- pegatinas.
- accesorios.
- insignias.
- álbum.

Modelos:

- `Reward`
- `Accessory`
- `Badge`

### speech

Responsable de:

- TTS.
- idioma de voz.
- velocidad.
- stop/speak.
- integración con AudioService para ducking.

Servicios:

- `SpeechService`
- `DeviceTtsSpeechService`

### audio

Responsable de:

- SFX.
- música.
- volúmenes.
- ducking.
- mute.

Servicios:

- `AudioService`
- `JustAudioService`

### progress

Responsable de:

- progreso local.
- niveles completados.
- último nivel jugado.
- recompensas desbloqueadas.

Modelos:

- `PlayerProgress`
- `LevelAttempt`

### settings

Responsable de:

- volumen música.
- volumen SFX.
- lectura automática.
- idioma.
- velocidad TTS.
- editar perfil.

## Flujo de arranque

```text
App arranca
  ↓
Carga perfil local
  ↓
Si no hay perfil → onboarding
  ↓
Si hay perfil → home
```

## Home

Debe mostrar:

- Continuar.
- Mapa.
- Práctica.
- Ayuda.
- Recompensas.
- Ajustes.

## Flujo de juego

```text
Seleccionar nivel
  ↓
Cargar LevelConfig
  ↓
Generar bolsa de operaciones válidas
  ↓
Crear sesión de nivel
  ↓
Generar Exercise final con plantilla, assets y textos localizados
  ↓
Responder
  ↓
Feedback
  ↓
Siguiente ejercicio
  ↓
Completar nivel
  ↓
Guardar progreso
```

## Persistencia

MVP:

- `shared_preferences`.

Guardar:

- `PlayerProfile`.
- `PlayerProgress`.
- `AppSettings`.

Futuro:

- Migrar a Hive/Isar si el progreso se vuelve complejo.

## Reglas técnicas

- Widgets no deben conocer detalles de TTS/audio.
- Widgets no deben generar ejercicios directamente.
- Generadores no deben depender de Flutter.
- Modelos de dominio deben ser testeables.
- Traducciones no deben estar hardcodeadas dentro de widgets permanentes.
