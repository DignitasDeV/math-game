# Style Guide

## Personalidad visual

La app debe sentirse:

- mágica.
- suave.
- amable.
- infantil.
- alegre.
- no competitiva.
- segura.
- clara.

## Paleta de colores

Definida en `lib/app/theme/app_colors.dart`.

### Fondos

```text
Blanco cálido (cloud):  #FFF8F0
Blanco puro:            #FFFFFF
Gradiente fondo:        #FFF8F0 → #F3E8FF (vertical)
```

### Primarios pastel

```text
Rosa mágico:            #F8A9D8
Lila suave:             #C7A4FF
Azul cielo:             #A9DDFB
Menta suave:            #BDF7D1
Amarillo estrella:      #FFE680
```

### Acentos saturados (botones, iconos activos)

```text
Rosa acento:            #FF6FAE
Lila acento:            #9B6FE8
Menta acento:           #4ECDC4
```

### Texto

```text
Morado texto:           #5C3A7D
Morado texto claro:     #8B6BAF
```

### Feedback

```text
Verde acierto:          #7ED957
Naranja pista:          #FFB84D
Error suave:            #FF9BAA
```

### Gradientes predefinidos

```text
backgroundGradient:     cloud → #F3E8FF (vertical)
magicGradient:          magicPink → softLilac (diagonal)
skyGradient:            skyBlue → softMint (diagonal)
```

## Uso de colores por contexto

### Fondos de pantalla

- Usar `AppColors.backgroundGradient` via `MagicScaffold`.
- No usar colores planos como fondo principal.

### Tarjetas / Tiles

- Fondo: color pastel al 15-18% de opacidad.
- Icono dentro de círculo blanco al 70%.
- Texto del título: versión oscura del color pastel (lightness 0.35).
- Bordes redondeados: 20px.
- Componente: `AppActionTile`.

### Botones principales

- `FilledButton`: rosa acento (#FF6FAE), texto blanco.
- `OutlinedButton`: borde lila suave, texto morado.
- Bordes: 16px.
- Altura mínima: 56px.

### Aciertos

- verde suave.
- sparkle.
- animación positiva.
- sonido amable.

### Errores

- no usar rojo fuerte.
- usar `gentleError` (#FF9BAA) o naranja pista.
- mensaje amable.
- ofrecer pista.

## Tipografía

Fuente: **Nunito** via `google_fonts`.

Definida en `lib/app/theme/app_typography.dart`.

```text
heading:       32px, w800, purpleText, letterSpacing -0.5
title:         26px, w700, purpleText
sectionTitle:  20px, w700, purpleText
body:          16px, w500, purpleTextLight
button:        18px, w700
caption:       13px, w500, purpleTextLight
```

Requisitos:

- buena lectura.
- soporte español y catalán (tildes, ç, apóstrofes).
- números claros.

## Iconos

Fuente principal: `material_symbols_icons` (variante `_rounded`).

Emojis nativos para:

- cabeceras de pantalla (AppScreenHeader).
- placeholder pages.
- splash.

Iconos funcionales desde `Symbols`:

- `Symbols.volume_up_rounded` — altavoz.
- `Symbols.tune_rounded` — ajustes.
- `Symbols.explore_rounded` — mapa.
- `Symbols.lightbulb_rounded` — ayuda.
- `Symbols.emoji_events_rounded` — premios.
- `Symbols.home_rounded` — inicio.
- `Symbols.arrow_forward_rounded` — continuar.
- `Symbols.group_rounded` — perfiles.
- `Symbols.person_add_rounded` — crear perfil.

## Componentes reutilizables

```text
AppActionTile          — tarjeta de acción con icono, label y color pastel
AppScreenHeader        — cabecera con emoji/icono + título + subtítulo
ResponsiveActionGrid   — grid responsive sin scroll (Expanded rows)
MagicScaffold          — scaffold con gradiente, AppBar transparente
PlaceholderPage        — página placeholder con emoji y badge "Proximamente"
```

## Animaciones

Usar animaciones cortas via `flutter_animate`.

Buenas:

- bounce.
- fade.
- sparkle.
- confeti breve.
- aparición suave.
- scale con elasticOut.

Evitar:

- animaciones largas.
- estímulos excesivos.
- parpadeos intensos.
- castigos visuales.

## Tono de texto

Mensajes cortos, positivos y claros.

Correcto:

```text
¡Genial!
¡Lo has conseguido!
¡Muy bien!
```

Error:

```text
Casi. Vamos a contarlo juntas.
Buena prueba. ¿Miramos una pista?
```

No usar:

```text
Mal.
Incorrecto.
Has fallado.
```

## Layout de pantalla de ejercicio

Elementos:

```text
Personaje
Enunciado (tarjeta blanca con sombra)
Botón altavoz (círculo pastel)
Visualización matemática
Opciones de respuesta
Botón pista
Progreso del nivel
```

Prioridad:

1. Enunciado.
2. Visualización.
3. Opciones.
4. Pista.
5. Recompensa/progreso.

## Accesibilidad

- botones grandes (mín. 56px).
- buen contraste (texto morado sobre fondo claro).
- TTS disponible.
- no depender solo de color.
- texto claro con fuente Nunito.
- evitar saturación visual.
