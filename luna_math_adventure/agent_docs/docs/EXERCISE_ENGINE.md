# Motor dinámico de ejercicios

## Objetivo

Evitar ejercicios fijos y repetitivos.

Los niveles se definen manualmente mediante reglas, pero los ejercicios concretos se generan dinámicamente.

## Problema a evitar

No hacer esto:

```text
Nivel 1:
1 + 2
2 + 1
3 + 1
```

Porque al repetir nivel, la niña memorizará las respuestas.

Tampoco hacer esto:

```dart
final a = Random().nextInt(20);
final b = Random().nextInt(20);
```

Porque puede generar ejercicios inadecuados para el nivel.

## Estrategia correcta

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

## LevelConfig

Define las reglas del nivel.

Ejemplo:

```json
{
  "id": "level_03",
  "title": "Sumas con corazones",
  "exerciseTypes": ["addition"],
  "minNumber": 1,
  "maxNumber": 5,
  "maxResult": 5,
  "allowNegativeResults": false,
  "allowCarry": false,
  "visualSupport": true,
  "questionsToComplete": 8
}
```

Campos recomendados:

- `id`
- `title`
- `worldId`
- `exerciseTypes`
- `minNumber`
- `maxNumber`
- `maxResult`
- `allowNegativeResults`
- `allowCarry`
- `visualSupport`
- `questionsToComplete`
- `starsToUnlockNext`

## OperationCandidate

Representa una operación válida antes de convertirla en ejercicio narrativo.

```dart
class OperationCandidate {
  final int a;
  final int b;
  final OperationType operation;
  final int result;
}
```

## Generación de bolsa

Para cada nivel se genera una bolsa de operaciones válidas.

Ejemplo de suma hasta 5 con resultado máximo 5:

```text
1 + 1
1 + 2
1 + 3
1 + 4
2 + 1
2 + 2
2 + 3
3 + 1
3 + 2
4 + 1
```

Luego se mezcla.

Ventajas:

- evita repetición excesiva.
- mantiene control pedagógico.
- permite repetir niveles con variedad.
- facilita tests.

## Reglas para sumas

Para cada `a` y `b`:

```text
a >= minNumber
b >= minNumber
a <= maxNumber
b <= maxNumber
a + b <= maxResult, si existe maxResult
```

Si `allowCarry` es false y se trabaja con dos cifras, evitar operaciones donde las unidades sumen 10 o más.

## Reglas para restas

Para cada `a` y `b`:

```text
a >= minNumber
b >= minNumber
a <= maxNumber
b <= maxNumber
a - b >= 0, si allowNegativeResults es false
a - b <= maxResult, si existe maxResult
```

En los primeros niveles no permitir negativos.

## Evitar repeticiones recientes

Mantener un historial de claves recientes.

Ejemplo:

```dart
class ExerciseSession {
  final List<String> recentExerciseKeys = [];

  bool wasRecentlyUsed(String key) {
    return recentExerciseKeys.contains(key);
  }

  void markAsUsed(String key) {
    recentExerciseKeys.add(key);
    if (recentExerciseKeys.length > 10) {
      recentExerciseKeys.removeAt(0);
    }
  }
}
```

Para suma, normalizar claves para que `2 + 3` y `3 + 2` puedan considerarse equivalentes si interesa.

```dart
String getExerciseKey(int a, int b, OperationType operation) {
  if (operation == OperationType.addition) {
    final values = [a, b]..sort();
    return '${values[0]}+${values[1]}';
  }

  return '$a-${b}';
}
```

## ExerciseTemplate

Permite convertir una operación en un ejercicio narrativo.

Debe estar localizado.

Ejemplo:

```json
{
  "id": "character_gets_more_items",
  "type": "addition",
  "texts": {
    "es-ES": {
      "visible": "{characterName} tiene {a} {itemPlural} y recibe {b} más. ¿Cuántos tiene?",
      "spoken": "{characterName} tiene {aWords} {itemPlural} y recibe {bWords} más. ¿Cuántos {itemPlural} tiene ahora?",
      "hint": "Cuenta primero {a}. Luego añade {b} más.",
      "spokenHint": "Cuenta primero {aWords}. Luego añade {bWords} más."
    },
    "ca-ES": {
      "visible": "{characterName} té {a} {itemPlural} i en rep {b} més. Quants en té?",
      "spoken": "{characterName} té {aWords} {itemPlural} i en rep {bWords} més. Quants {itemPlural} té ara?",
      "hint": "Compta primer {a}. Després afegeix-ne {b} més.",
      "spokenHint": "Compta primer {aWords}. Després afegeix-ne {bWords} més."
    }
  }
}
```

## Exercise final

Modelo recomendado:

```dart
class Exercise {
  final String id;
  final ExerciseType type;
  final int level;
  final int a;
  final int b;
  final OperationType operation;
  final int correctAnswer;
  final List<int> options;
  final LocalizedText visibleQuestion;
  final LocalizedText spokenQuestion;
  final LocalizedText visibleHint;
  final LocalizedText spokenHint;
  final List<VisualItemInstance> visualItems;
}
```

## Opciones de respuesta

Generar opciones cercanas pero razonables.

Para `12 + 17 = 29`:

```text
27
28
29
30
```

Evitar opciones demasiado absurdas en niveles iniciales.

## Pistas avanzadas

Para `12 + 17`:

```text
12 es 10 y 2.
17 es 10 y 7.
10 + 10 = 20.
2 + 7 = 9.
20 + 9 = 29.
```

Debe tener versión catalana y texto hablado separado.

## Tests mínimos

- suma hasta 5 no supera resultado 5.
- resta no genera negativos si no se permite.
- bolsa no está vacía.
- opciones contienen la respuesta correcta.
- opciones no se repiten.
- ejercicios recientes no se repiten.
- plantillas tienen `es-ES` y `ca-ES`.
