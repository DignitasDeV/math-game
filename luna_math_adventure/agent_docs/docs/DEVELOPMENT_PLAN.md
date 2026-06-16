# Development Plan

Plan de trabajo para empezar el desarrollo real de Luna Math Adventure.

## Objetivo inmediato

Convertir la base actual en un MVP jugable:

- onboarding funcional.
- perfiles infantiles guardados por familia/dispositivo.
- progreso separado por perfil infantil.
- home navegable.
- primer nivel jugable.
- ejercicio generado dinamicamente.
- TTS para enunciado y pista.
- SFX de acierto/error.
- feedback amable.
- progreso local minimo.

## Regla responsive

La app debe funcionar principalmente en movil y tablet.

- Las pantallas principales deben caber en viewport sin scroll.
- No usar scroll como solucion por defecto.
- Usar layouts adaptativos por ancho y alto disponibles.
- En tablet, limitar el ancho util para que los controles no queden demasiado estirados.
- En movil bajo, compactar espaciados y tamanos antes de recurrir a scroll.
- Los botones principales deben seguir siendo grandes y faciles de tocar.
- El flujo de juego, onboarding, home y ejercicio deben ser fit-to-screen.

## Fase 1: Base funcional de perfil

### Tareas

- Revisar rutas actuales.
- Crear providers de perfil.
- Guardar lista de `PlayerProfile` con `shared_preferences`.
- Mantener un perfil activo.
- Guardar el progreso usando el `profileId` activo.
- Cargar familia/perfiles al arrancar.
- Redirigir desde splash:
  - sin perfil: onboarding.
  - con perfiles pero sin activo: selector de perfiles.
  - con perfil: home.
- Conectar pantallas:
  - idioma.
  - nombre de la nina.
  - variante unicornio/unicornia.
  - nombre del personaje.

### Criterio de exito

- La app recuerda el idioma y los nombres tras cerrar y abrir.
- Cada nina o nino puede tener su propio perfil.
- Cada perfil tendra progreso independiente.
- El onboarding aparece para crear perfiles nuevos.
- Si existen varios perfiles, la familia puede elegir quien juega.

## Fase 2: Localizacion MVP

### Tareas

- Crear helper para obtener textos segun idioma.
- Cargar textos desde `assets/data/localization.json` o `assets/data/i18n`.
- Evitar textos importantes hardcodeados en pantallas principales.
- Preparar textos visibles y hablados separados.

### Criterio de exito

- Cambiar idioma afecta al flujo principal.
- TTS usa `es-ES` o `ca-ES`.

## Fase 3: Primer ejercicio jugable

### Tareas

- Revisar `ExerciseGenerator`, `OptionGenerator` y `HintGenerator`.
- Crear una sesion simple de nivel.
- Leer `levels.json`.
- Generar una operacion valida para el nivel.
- Generar opciones de respuesta.
- Validar respuesta.
- Mostrar feedback correcto/error.
- Boton de pista.
- Boton de altavoz.

### Criterio de exito

- Se puede responder un ejercicio.
- Hay feedback visual.
- La respuesta correcta se detecta.
- La pista se puede leer.

## Fase 4: Audio/TTS MVP

### Tareas

- Completar `SpeechService` con `flutter_tts`.
- Completar `AudioService` con `just_audio`.
- Manejar fallback si faltan archivos SFX `.wav`.
- Usar SFX cuando existan assets reales.
- Mantener la app estable con placeholders.

### Criterio de exito

- El altavoz lee el enunciado.
- El boton de pista puede leer la pista.
- Los SFX no rompen la app si el asset aun no existe.

## Fase 5: Progreso minimo

### Tareas

- Crear persistencia de:
  - ultimo nivel jugado.
  - niveles completados.
  - estrellas por nivel.
- Crear boton continuar.
- Permitir repetir nivel completado.

### Criterio de exito

- Completar un nivel se guarda localmente.
- Home puede continuar desde el ultimo nivel.

## Fase 6: Mapa inicial

### Tareas

- Leer `worlds.json` y `levels.json`.
- Mostrar mundos y niveles.
- Diferenciar bloqueado/desbloqueado/completado.
- Entrar en un nivel desbloqueado.

### Criterio de exito

- El mapa permite navegar a niveles disponibles.

## Primera tarea recomendada

Empezar por la Fase 1:

1. Revisar modelos actuales de perfil.
2. Implementar repositorio real de perfiles/progreso con `shared_preferences`.
3. Conectar splash y onboarding.
4. Verificar en Chrome.

Esta fase desbloquea el resto porque deja idioma, perfil y rutas bien asentadas.
