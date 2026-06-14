# Assets

## Estrategia general

No generar todo con IA.

Usar IA para assets de identidad visual y librerías/packs para elementos funcionales o genéricos.

## IA generativa

Usar IA para elementos únicos del juego:

- Unicornio/unicornia principal.
- Variantes masculina y femenina.
- Fondos de mundos.
- Escenarios narrativos.
- Recompensas especiales.
- Pegatinas grandes.
- Accesorios mágicos.
- Ilustraciones de portada.
- Ilustraciones del mapa.

## Librerías o packs

Usar librerías/packs para elementos reutilizables:

- Iconos funcionales.
- Botones.
- Paneles.
- Estrellas simples.
- Corazones simples.
- Candados.
- Trofeos.
- Confeti.
- Sparkles.
- Animaciones de éxito.
- Loading.
- Check/correcto.
- Pista.
- Altavoz.

## Fuentes recomendadas

### Iconos en Flutter

- Material Icons.
- material_symbols_icons.
- font_awesome_flutter.

Uso:

- altavoz.
- ajustes.
- casa.
- repetir.
- continuar.
- pista.
- cerrar.
- play/pause.
- candado.
- estrella.
- corazón.
- trofeo.

### Packs externos

- Kenney Game Icons.
- Kenney UI Pack.
- Kenney UI Pack Adventure.

Uso:

- botones.
- paneles.
- marcos.
- iconos de videojuego.
- estrellas.
- corazones.
- candados.
- trofeos.

### Animaciones

- LottieFiles.
- Lottie JSON.
- flutter_animate para microanimaciones.

Uso:

- confeti.
- sparkle.
- recompensa desbloqueada.
- éxito.
- transición suave.
- loading mágico.

### Rive futuro

No necesario para MVP.

Usar más adelante si se quiere animar el personaje principal con estados:

- idle.
- happy.
- thinking.
- celebrating.
- encouraging.

## Checklist de assets IA

### Personaje femenino

```text
assets/images/characters/unicorn_female/
  idle.webp
  happy.webp
  thinking.webp
  celebrating.webp
  encouraging.webp
```

### Personaje masculino

```text
assets/images/characters/unicorn_male/
  idle.webp
  happy.webp
  thinking.webp
  celebrating.webp
  encouraging.webp
```

### Fondos

```text
assets/images/backgrounds/
  heart_forest.webp
  star_lake.webp
  rainbow_path.webp
  crystal_castle.webp
  magic_tower.webp
  home_background.webp
  map_background.webp
```

### Objetos matemáticos

Estos pueden generarse con IA o venir de packs si encajan.

```text
assets/images/items/
  heart_pink.webp
  star_yellow.webp
  flower_blue.webp
  gem_purple.webp
  cloud_white.webp
  cupcake_pink.webp
  ten_block.webp
  unit_cube.webp
```

Importante para decenas/unidades:

```text
ten_block.webp
unit_cube.webp
```

### Recompensas especiales

```text
assets/images/rewards/accessories/
  crown_pink.webp
  bow_heart.webp
  wings_rainbow.webp
  magic_wand.webp
  necklace_star.webp

assets/images/rewards/stickers/
  sticker_heart.webp
  sticker_star.webp
  sticker_unicorn.webp
  sticker_rainbow.webp

assets/images/rewards/badges/
  badge_first_sum.webp
  badge_10_correct.webp
  badge_subtraction_beginner.webp
  badge_level_complete.webp
```

## Checklist de assets de librería/packs

```text
assets/images/ui/
  icon_speaker.svg
  icon_home.svg
  icon_settings.svg
  icon_replay.svg
  icon_continue.svg
  icon_hint.svg
  icon_lock.svg
  icon_check.svg
  icon_close.svg
  icon_star.svg
  icon_heart.svg
  icon_trophy.svg
```

Botones y paneles si se usan packs:

```text
assets/images/ui/panels/
  panel_small.webp
  panel_medium.webp
  panel_large.webp

assets/images/ui/buttons/
  button_primary.webp
  button_secondary.webp
```

## Animaciones

```text
assets/animations/
  confetti.json
  sparkle_burst.json
  reward_unlock.json
  success_star.json
  magic_loading.json
```

## Audio

Ver `docs/AUDIO_TTS.md`.

## Datos

```text
assets/data/
  levels.json
  worlds.json
  visual_items.json
  rewards.json
  exercise_templates.json
  help_topics.json
  localization.json
```

## Licencias

Crear:

```text
assets/licenses/
  image_generation_notes.md
  audio_licenses.md
  icon_licenses.md
  animation_licenses.md
```

Cada asset externo debe documentar:

- nombre.
- fuente.
- URL.
- licencia.
- fecha de descarga.
- si requiere atribución.

## Naming convention

Usar nombres claros:

```text
character_unicorn_female_idle.webp
item_heart_pink.webp
reward_crown_pink.webp
sfx_correct_01.mp3
animation_confetti_01.json
```

Evitar:

```text
imagen1.png
final_final.png
unicornio_bueno_definitivo.png
```
