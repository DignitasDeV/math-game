# Roadmap de desarrollo

## Objetivo general

Construir una app Flutter educativa, divertida y escalable para practicar matemáticas básicas con una estética mágica de unicornios/unicornias.

La app debe empezar sencilla, pero estar preparada para crecer.

## Stage 0: Setup del proyecto

Objetivo: preparar una base técnica limpia.

Tareas:

- Crear proyecto Flutter.
- Configurar dependencias.
- Crear estructura modular por features.
- Crear tema visual inicial.
- Crear rutas.
- Crear providers base.
- Crear carpetas de assets.
- Crear documentación.
- Crear JSON de datos iniciales.
- Crear pantalla de prueba de TTS/audio.

Criterio de éxito:

- La app arranca.
- Hay navegación básica.
- El TTS puede leer una frase.
- Se puede reproducir un SFX local.
- El proyecto tiene estructura clara.

## Stage 1: Onboarding y perfil

Objetivo: permitir personalizar la experiencia.

Tareas:

- Pantalla de selección de idioma.
- Pantalla de nombre de la niña.
- Pantalla de selección de unicornio/unicornia.
- Pantalla de nombre del personaje.
- Guardar perfil localmente.
- Cargar perfil al arrancar.
- Permitir editar desde ajustes.

Criterio de éxito:

- La app sabe el idioma seleccionado.
- La app sabe el nombre de la niña.
- La app sabe si el personaje es masculino o femenino.
- La app sabe el nombre del personaje.
- Si ya existe perfil, salta el onboarding.

## Stage 2: Prototipo jugable

Objetivo: crear un primer ejercicio funcional.

Tareas:

- Crear modelo `Exercise`.
- Crear `LevelConfig`.
- Crear `OperationCandidate`.
- Crear generador básico de suma/resta.
- Crear pantalla de ejercicio.
- Mostrar enunciado.
- Mostrar respuestas.
- Validar respuesta.
- Mostrar feedback correcto/error.
- Botón de altavoz para enunciado.
- Botón de pista.
- SFX de acierto/error.

Criterio de éxito:

- La niña puede resolver un ejercicio.
- El enunciado se puede escuchar.
- La pista se puede escuchar.
- Hay feedback visual y sonoro.

## Stage 3: Motor dinámico de ejercicios

Objetivo: evitar ejercicios fijos y repetitivos.

Tareas:

- Crear `ExercisePoolGenerator`.
- Generar bolsa de operaciones válidas por nivel.
- Mezclar bolsa en cada sesión.
- Evitar repeticiones recientes.
- Crear plantillas narrativas.
- Crear `OptionGenerator`.
- Crear `HintGenerator`.
- Añadir textos localizados.
- Añadir soporte de objetos visuales.

Criterio de éxito:

- Repetir un nivel no muestra siempre los mismos ejercicios.
- Los ejercicios siguen siendo pedagógicamente controlados.
- Los textos varían mediante plantillas.

## Stage 4: Niveles y progreso

Objetivo: convertir ejercicios sueltos en niveles jugables.

Tareas:

- Crear `levels.json`.
- Crear mundos y niveles.
- Completar nivel tras X preguntas.
- Guardar nivel completado.
- Guardar último nivel jugado.
- Guardar estrellas/recompensas.
- Permitir repetir niveles.
- Permitir entrar en niveles desbloqueados.
- Crear botón Continuar.

Criterio de éxito:

- Se puede continuar desde el último nivel.
- Se puede repetir un nivel.
- Se puede entrar en cualquier nivel desbloqueado.
- El progreso queda guardado.

## Stage 5: Mapa y recompensas

Objetivo: dar sensación de aventura.

Tareas:

- Crear mapa de mundos.
- Crear nodos de nivel.
- Mostrar niveles bloqueados/desbloqueados.
- Crear sistema de recompensas.
- Crear álbum.
- Desbloquear pegatinas/accesorios.
- Mostrar pantalla de recompensa.

Criterio de éxito:

- Completar niveles desbloquea contenido.
- El mapa permite navegar libremente por niveles disponibles.

## Stage 6: Modo práctica y centro de ayuda

Objetivo: hacer la app menos rígida y más educativa.

Tareas:

- Crear modo práctica libre.
- Permitir escoger tipo de ejercicio.
- Permitir escoger dificultad.
- Crear centro de ayuda.
- Crear temas: unidades, decenas, sumar, restar, descomponer.
- Añadir ejemplos visuales.
- Añadir lectura TTS en ayuda.
- Traducir ayuda a español y catalán.

Criterio de éxito:

- La niña puede practicar sin avanzar en el mapa.
- Puede consultar explicaciones básicas.
- Las explicaciones se pueden escuchar.

## Stage 7: Números hasta 20

Objetivo: ampliar contenido matemático.

Tareas:

- Añadir mundos hasta 20.
- Sumas con resultado hasta 20.
- Restas desde números hasta 20.
- Visualización de decenas/unidades.
- Pistas específicas.
- Plantillas narrativas adaptadas.

Criterio de éxito:

- La app cubre práctica real hasta el 20.

## Stage 8: Operaciones avanzadas

Objetivo: introducir operaciones tipo `12 + 17`.

Tareas:

- Crear mundo avanzado.
- Sumas entre 10 y 20.
- Resultados hasta 40.
- Restas más complejas hasta 20.
- Pistas por descomposición.
- Representación visual de decenas y unidades.
- Opciones de respuesta con errores típicos controlados.

Criterio de éxito:

- La app puede generar y explicar ejercicios como `12 + 17`.

## Stage 9: Pulido

Objetivo: mejorar experiencia y calidad.

Tareas:

- Mejorar animaciones.
- Añadir música final.
- Añadir más SFX.
- Sustituir placeholders por assets finales.
- Añadir ajustes parentales.
- Mejorar accesibilidad.
- Añadir tests.
- Optimizar rendimiento.
- Revisar licencias.

Criterio de éxito:

- App estable, bonita y lista para uso familiar continuo.
