# AGENTS.md

## Rol del agente

Actúa como desarrollador senior Flutter/Dart. Tu objetivo es ayudar a construir una app educativa infantil llamada `Luna Math Adventure`.

Prioriza:

1. Código limpio.
2. Arquitectura modular.
3. MVP funcional.
4. Extensibilidad.
5. UX infantil amable.
6. Separación entre lógica, UI, datos y servicios.
7. Soporte bilingüe desde el inicio.

## Reglas generales

- No crear soluciones monolíticas.
- No hardcodear ejercicios fijos como contenido principal.
- No usar `Random()` sin restricciones pedagógicas.
- No mezclar lógica de generación de ejercicios dentro de widgets.
- No mezclar TTS/audio directamente en pantallas sin pasar por servicios.
- No bloquear el avance por errores de la niña.
- No usar rojo agresivo para fallos.
- No crear backend en el MVP.
- No añadir paquetes innecesarios si no aportan valor claro.
- No asumir que el personaje se llama siempre Luna.
- No asumir que el personaje es siempre femenino.
- No asumir que la app es solo en español.

## Arquitectura

Usar arquitectura por features.

Estructura base:

```text
lib/
  app/
  core/
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

Cada feature puede tener:

```text
domain/
application/
infrastructure/
presentation/
```

## Estado

Usar Riverpod.

Preferencias:

- Providers para servicios.
- Notifier/AsyncNotifier o StateNotifier para controladores.
- Mantener los modelos de dominio independientes de Flutter cuando sea posible.
- No meter lógica de negocio pesada en widgets.

## Navegación

Usar go_router.

Rutas esperadas:

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

Lógica:

```text
Si no hay perfil:
  ir a onboarding

Si hay perfil:
  ir a home
```

Home debe tener:

- Continuar.
- Mapa.
- Práctica.
- Ayuda.
- Recompensas.
- Ajustes.

## Tema visual

Usar colores pastel y formas redondeadas.

Paleta inicial:

```text
Rosa pastel:        #F8A9D8
Lila suave:         #C7A4FF
Azul cielo:         #A9DDFB
Menta suave:        #BDF7D1
Amarillo estrella:  #FFE680
Blanco cálido:      #FFF8F0
Morado texto:       #5C3A7D
Verde acierto:      #7ED957
Naranja pista:      #FFB84D
```

## Localización e idioma

La app debe ser bilingüe desde el inicio.

Idiomas soportados inicialmente:

- Español: `es-ES`
- Catalán: `ca-ES`

El idioma se escoge en la pantalla inicial de onboarding y puede modificarse después desde ajustes.

No hardcodear textos permanentes directamente en widgets.

Todo texto relevante debe poder traducirse:

- UI.
- Enunciados.
- Pistas.
- Centro de ayuda.
- Feedback.
- Recompensas.
- Ajustes.
- Textos hablados por TTS.
- Nombres singulares/plurales de objetos visuales.

Separar siempre:

- texto visible.
- texto hablado.

El TTS debe usar el idioma activo:

```dart
speechService.setLanguage(selectedLanguage.localeCode);
```

## Perfil y personalización

La app debe permitir:

- Nombre de la niña.
- Personaje masculino o femenino.
- Nombre del unicornio/unicornia.

Nombres por defecto:

- Unicornia: Luna.
- Unicornio: Luno.

Modelo esperado:

```dart
class PlayerProfile {
  final String childName;
  final AppLanguage language;
  final UnicornVariant unicornVariant;
  final String unicornName;
}
```

Enums esperados:

```dart
enum UnicornVariant {
  female,
  male,
}
```

## Audio y TTS

Crear una abstracción `SpeechService`.

No llamar directamente a `FlutterTts` desde widgets.

Crear una abstracción `AudioService`.

No llamar directamente a `AudioPlayer` desde widgets.

Regla de prioridad:

```text
TTS > SFX > música
```

Cuando el TTS hable, la música debe bajar de volumen temporalmente.

## Ejercicios

El sistema de ejercicios debe funcionar así:

```text
LevelConfig
  ↓
ExercisePoolGenerator
  ↓
OperationCandidate
  ↓
ExerciseTemplate
  ↓
Exercise final
```

Los niveles definen reglas:

- tipo de ejercicio.
- mínimo.
- máximo.
- resultado máximo.
- si permite negativos.
- si permite llevar.
- cantidad de preguntas.
- soporte visual.

Los ejercicios se generan dinámicamente.

Evitar repeticiones recientes.

Separar:

- texto visible.
- texto hablado.
- pista visible.
- pista hablada.

Ejemplo:

```dart
visibleQuestion: "12 + 17 = ?"
spokenQuestion: "Doce más diecisiete. ¿Cuánto es?"
visibleHint: "Separa los números en decenas y unidades."
spokenHint: "Doce es diez y dos. Diecisiete es diez y siete."
```

También debe existir versión catalana de todos estos textos.

## Libertad de progreso

La app no debe ser rígida ni encorsetada.

Debe permitir:

- continuar desde el último nivel jugado.
- repetir niveles completados.
- entrar en cualquier nivel desbloqueado.
- jugar modo práctica libre.
- volver al mapa cuando quiera.
- practicar conceptos sin afectar negativamente el progreso.

## Centro de ayuda

Crear una sección `HelpCenter`.

Debe explicar conceptos matemáticos con ejemplos visuales:

- números.
- contar.
- unidades.
- decenas.
- suma.
- resta.
- descomposición.
- números hasta 20.

Cada tema debe tener:

- título.
- explicación breve.
- ejemplo visual.
- texto hablado.
- botón de altavoz.
- traducción española y catalana.

## Assets

IA para:

- personaje principal.
- versión femenina.
- versión masculina.
- fondos.
- mundos.
- recompensas especiales.
- pegatinas grandes.
- accesorios personalizados.

Librerías/packs para:

- iconos funcionales.
- botones genéricos.
- estrellas/corazones simples.
- candados.
- trofeos.
- confeti.
- sparkles.
- animaciones de feedback.

Mantener documentación de licencias en:

```text
assets/licenses/
```

## Tests

Crear tests unitarios para:

- generación de sumas.
- generación de restas.
- filtros de nivel.
- evitar negativos.
- maxResult.
- generación de opciones.
- evitar repeticiones recientes.
- selección de idioma.
- recuperación de perfil.
- niveles repetibles/desbloqueados.

## Prioridad actual

Primera meta:

Crear una base funcional con:

- app arrancando.
- rutas principales.
- tema visual.
- onboarding inicial.
- idioma español/catalán.
- perfil básico.
- TTS de prueba.
- SFX de prueba.
- pantalla de ejercicio simple.
- estructura modular.
- documentación inicial.

No implementar todavía todos los mundos ni recompensas finales.
