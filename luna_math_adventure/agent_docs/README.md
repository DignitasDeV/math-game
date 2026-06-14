# Luna Math Adventure

Juego educativo infantil de matemáticas desarrollado con Flutter y Dart.

El objetivo del proyecto es crear una experiencia divertida, visual, flexible y progresiva para practicar conteo, sumas y restas. La app está pensada inicialmente para una niña de 6 años, con una estética mágica basada en unicornios/unicornias, corazones, estrellas, arcoíris, recompensas y mundos desbloqueables.

## Visión

La app no debe sentirse como un examen. Debe sentirse como una aventura interactiva donde la niña ayuda a su unicornio o unicornia resolviendo pequeños retos matemáticos.

Principios de producto:

- Juego visual y amable.
- Ejercicios dinámicos.
- Niveles repetibles.
- Progreso flexible.
- Lectura en voz alta.
- Pistas disponibles.
- Sin castigos por error.
- Recompensas frecuentes.
- Personalización del nombre de la niña.
- Personalización del nombre y género del unicornio/unicornia.
- Bilingüe desde el inicio: español y catalán.
- Arquitectura preparada para crecer.

## Stack técnico

- Flutter
- Dart
- flutter_riverpod
- go_router
- flutter_tts
- just_audio
- shared_preferences
- flutter_svg
- lottie
- flutter_animate
- font_awesome_flutter
- material_symbols_icons

## Decisiones principales

### Estado

Se usará Riverpod para estado, servicios y dependencias.

### Navegación

Se usará go_router para rutas declarativas.

### Voz

Los enunciados y pistas se leerán usando TTS local del dispositivo mediante flutter_tts.

### Audio

La música y los efectos de sonido se reproducirán desde assets locales mediante just_audio.

### Idiomas

La app debe ser bilingüe desde el inicio:

- Español: `es-ES`
- Catalán: `ca-ES`

En la pantalla inicial/onboarding se podrá escoger el idioma. El idioma seleccionado afectará a UI, ejercicios, pistas, ayuda, recompensas, textos hablados y TTS.

### Ejercicios

Los ejercicios no se introducirán manualmente uno a uno.

La estrategia correcta es:

1. Definir niveles manualmente mediante reglas.
2. Generar una bolsa de operaciones válidas para cada nivel.
3. Mezclar la bolsa en cada sesión.
4. Sacar ejercicios de la bolsa.
5. Evitar repeticiones recientes.
6. Aplicar plantillas narrativas para variar el texto.
7. Generar opciones de respuesta de manera controlada.

Ejemplo de configuración de nivel:

```json
{
  "id": "level_03",
  "title": "Sumas con corazones",
  "exerciseTypes": ["addition"],
  "minNumber": 1,
  "maxNumber": 5,
  "maxResult": 5,
  "questionsToComplete": 8,
  "visualSupport": true
}
```

El motor generará dinámicamente operaciones válidas como:

```text
1 + 1
1 + 2
1 + 3
2 + 1
2 + 2
3 + 1
```

Cada vez que se juegue el nivel, el orden y las plantillas narrativas podrán cambiar.

## Modos de juego

### Continuar

Permite seguir desde el último nivel jugado.

### Mapa

Permite entrar en cualquier nivel desbloqueado.

### Repetir nivel

Los niveles completados pueden repetirse siempre.

### Modo práctica

Permitirá practicar libremente una categoría:

- Conteo
- Sumas hasta 5
- Restas hasta 5
- Sumas hasta 10
- Restas hasta 10
- Sumas hasta 20
- Restas hasta 20
- Sumas avanzadas con números entre 10 y 20

### Centro de ayuda

Sección explicativa con conceptos matemáticos básicos:

- Números
- Contar
- Unidades
- Decenas
- Sumar
- Restar
- Descomponer números
- Sumas hasta 20
- Restas hasta 20

## Progresión matemática

### Mundo 1: Bosque de Corazones

- Contar del 1 al 5.
- Sumas hasta 5.
- Restas muy sencillas.

### Mundo 2: Lago de Estrellas

- Sumas hasta 10.
- Restas hasta 10.
- Mezcla de suma/resta.

### Mundo 3: Camino Arcoíris

- Números del 10 al 20.
- Conteo hasta 20.
- Sumas con resultado hasta 20.
- Restas desde números hasta 20.

### Mundo 4: Castillo de Cristal

- Sumas y restas más complejas hasta 20.
- Introducción de decenas y unidades.
- Ejercicios tipo `14 + 5`, `18 - 6`, `20 - 12`.

### Mundo 5: Torre Mágica

- Operaciones con dos números entre 10 y 20.
- Ejercicios tipo `12 + 17`.
- Pistas con descomposición:
  - `12 = 10 + 2`
  - `17 = 10 + 7`
  - `10 + 10 = 20`
  - `2 + 7 = 9`
  - `20 + 9 = 29`

## Assets

### IA generativa

Se usará IA para assets de identidad visual:

- Unicornio/unicornia principal.
- Variantes masculina/femenina.
- Fondos de mundos.
- Escenarios.
- Recompensas especiales.
- Pegatinas grandes.
- Accesorios mágicos.

### Librerías y packs

Se usarán librerías o packs para elementos genéricos:

- Icono de altavoz.
- Icono de casa.
- Icono de ajustes.
- Icono de repetir.
- Icono de continuar.
- Icono de pista.
- Estrellas simples.
- Corazones simples.
- Candados.
- Trofeos.
- Confeti.
- Sparkles.
- Animaciones de éxito.

## Estructura inicial

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

## Primer objetivo técnico

Crear una base funcional con:

- App Flutter arrancando.
- Tema visual pastel.
- Rutas principales.
- Pantallas placeholder.
- Onboarding con selección de idioma.
- Onboarding con nombre de niña.
- Onboarding con selección de unicornio/unicornia.
- TTS funcionando.
- SFX funcionando.
- Assets declarados.
- Estructura modular.
- Primer ejercicio de suma renderizado.
- Botón de altavoz leyendo el enunciado.
- Botón de pista leyendo la pista.
- Feedback básico de respuesta correcta/incorrecta.

## Roadmap resumido

### Stage 0: Setup

Preparar proyecto, dependencias, estructura, documentación y pantallas placeholder.

### Stage 1: Onboarding y perfil

Idioma, nombre de la niña, género del unicornio/unicornia y nombre del personaje.

### Stage 2: Prototipo jugable

Un ejercicio de suma/resta con TTS, pista, respuestas y feedback.

### Stage 3: Niveles

Sistema de niveles, progreso local y generación dinámica de ejercicios.

### Stage 4: Mapa y recompensas

Mapa desbloqueable, repetición de niveles, recompensas y álbum.

### Stage 5: Modo práctica y ayuda

Modo libre de práctica y centro de ayuda matemática.

### Stage 6: Números hasta 20

Sumas/restas hasta 20 con apoyo visual.

### Stage 7: Operaciones avanzadas

Ejercicios tipo `12 + 17`, decenas/unidades y descomposición.

### Stage 8: Pulido

Animaciones, música, assets finales, ajustes parentales y mejora UX.

## Documentación

Consultar:

- `AGENTS.md`
- `docs/ROADMAP.md`
- `docs/TECH_STACK.md`
- `docs/ARCHITECTURE.md`
- `docs/GAME_DESIGN.md`
- `docs/EXERCISE_ENGINE.md`
- `docs/ASSETS.md`
- `docs/AUDIO_TTS.md`
- `docs/STYLE_GUIDE.md`
- `docs/I18N.md`
