# Visual Asset Audit

Estado revisado contra `lib/`, `assets/data/`, `assets/images/` y `assets/animations/`.

## Cubierto ahora

- Fondos de pantalla y tarjetas de mundos:
  - `assets/images/backgrounds/*_screen.webp`
  - `assets/images/backgrounds/*_card.webp`
- Unicornia femenina:
  - `assets/images/characters/unicorn_female/idle.webp`
  - `assets/images/characters/unicorn_female/happy.webp`
  - `assets/images/characters/unicorn_female/thinking.webp`
  - `assets/images/characters/unicorn_female/encouraging.webp`
  - `assets/images/characters/unicorn_female/celebrating.webp`
- Botones de navegacion usados:
  - `assets/images/ui/buttons/prev.webp`
  - `assets/images/ui/buttons/next.webp`

## Faltan - IA generativa

Estos assets son ilustrativos/narrativos y encajan bien con IA, manteniendo estilo coherente con los `.md` existentes.

### Personaje masculino

La app referencia `idle.webp` en seleccion de variante y puede pedir todos los estados en juego.

- `assets/images/characters/unicorn_male/idle.webp`
- `assets/images/characters/unicorn_male/happy.webp`
- `assets/images/characters/unicorn_male/thinking.webp`
- `assets/images/characters/unicorn_male/encouraging.webp`
- `assets/images/characters/unicorn_male/celebrating.webp`

### Objetos matematicos

Referenciados por `assets/data/visual_items.json`; ahora caen a fallback.

- `assets/images/items/heart_pink.webp`
- `assets/images/items/star_yellow.webp`
- `assets/images/items/flower_blue.webp`
- `assets/images/items/cupcake_pink.webp`
- `assets/images/items/cloud_white.webp`
- `assets/images/items/gem_purple.webp`
- `assets/images/items/ten_block.webp`
- `assets/images/items/unit_cube.webp`

Nota: `ten_block.webp` y `unit_cube.webp` deberian ser mas didacticos que decorativos; pueden hacerse con IA, pero tambien son buenos candidatos a vector/controlado manualmente para claridad.

### Recompensas referenciadas por datos

Referenciadas en `assets/data/rewards.json`; la pantalla de recompensas aun es placeholder, pero estos paths ya forman parte del contenido.

Accesorios:

- `assets/images/rewards/accessories/bow_heart.webp`
- `assets/images/rewards/accessories/crown_pink.webp`
- `assets/images/rewards/accessories/tiara_star_lake.webp`
- `assets/images/rewards/accessories/cape_rainbow.webp`
- `assets/images/rewards/accessories/crown_crystal.webp`
- `assets/images/rewards/accessories/crown_magic_tower.webp`

Pegatinas:

- `assets/images/rewards/stickers/sticker_heart.webp`
- `assets/images/rewards/stickers/sticker_star.webp`
- `assets/images/rewards/stickers/sticker_lake_star.webp`
- `assets/images/rewards/stickers/sticker_moon_lake.webp`
- `assets/images/rewards/stickers/sticker_rainbow_cloud.webp`
- `assets/images/rewards/stickers/sticker_crystal_gem.webp`
- `assets/images/rewards/stickers/sticker_magic_tower.webp`

Insignias:

- `assets/images/rewards/badges/badge_first_sum.webp`
- `assets/images/rewards/badges/badge_subtraction_beginner.webp`
- `assets/images/rewards/badges/badge_lake_addition.webp`
- `assets/images/rewards/badges/badge_lake_subtraction.webp`
- `assets/images/rewards/badges/badge_count_to_20.webp`
- `assets/images/rewards/badges/badge_rainbow_addition.webp`
- `assets/images/rewards/badges/badge_rainbow_subtraction.webp`
- `assets/images/rewards/badges/badge_units_tens.webp`
- `assets/images/rewards/badges/badge_crystal_addition.webp`
- `assets/images/rewards/badges/badge_crystal_subtraction.webp`
- `assets/images/rewards/badges/badge_big_addition.webp`
- `assets/images/rewards/badges/badge_big_subtraction.webp`
- `assets/images/rewards/badges/badge_advanced_addition.webp`

## Faltan o son opcionales - no IA

Estos deberian venir de Flutter, librerias de iconos, Lottie/Rive o packs con licencia clara. No hace falta generarlos con IA salvo que se quiera un pack visual cerrado.

### UI funcional

Actualmente hay placeholders `.md`, pero la app usa principalmente `Icons`, `material_symbols_icons`, botones Flutter y estilos propios.

- `assets/images/ui/icon_speaker.svg`
- `assets/images/ui/icon_home.svg`
- `assets/images/ui/icon_settings.svg`
- `assets/images/ui/icon_replay.svg`
- `assets/images/ui/icon_continue.svg`
- `assets/images/ui/icon_hint.svg`
- `assets/images/ui/icon_lock.svg`
- `assets/images/ui/icon_check.svg`
- `assets/images/ui/icon_close.svg`
- `assets/images/ui/icon_star.svg`
- `assets/images/ui/icon_heart.svg`
- `assets/images/ui/icon_trophy.svg`
- `assets/images/ui/buttons/button_primary.webp`
- `assets/images/ui/buttons/button_secondary.webp`
- `assets/images/ui/panels/panel_small.webp`
- `assets/images/ui/panels/panel_medium.webp`
- `assets/images/ui/panels/panel_large.webp`

Recomendacion: mantener estos como Flutter/widgets salvo que se decida comprar/usar un pack UI completo.

### Animaciones visuales

Solo existen `.md`. Decision: no tratarlas como assets visuales pendientes para IA.

Recomendacion: implementarlas con Flutter y `flutter_animate`, usando particulas simples, iconos, opacity/scale/slide y tweens propios. Si mas adelante se quiere una animacion muy concreta, entonces valorar Lottie/Rive con licencia clara.

Implementacion inicial:

- `lib/features/rewards/rewards_screen.dart`: entrada animada de tarjetas y brillo en la medalla de coleccion.
- `lib/features/game/game_screen.dart`: celebracion de nivel completado con fade/scale/slide y brillo en estrellas.

- `assets/animations/confetti.json`
- `assets/animations/sparkle_burst.json`
- `assets/animations/reward_unlock.json`
- `assets/animations/success_star.json`
- `assets/animations/magic_loading.json`

## Placeholders incorporados en codigo

Estos placeholders ya estan referenciados por `rewards.json` y la pantalla de recompensas puede renderizarlos con iconos/widgets Flutter aunque no exista el `.webp`.

- `assets/images/rewards/accessories/magic_wand.md`
- `assets/images/rewards/accessories/necklace_star.md`
- `assets/images/rewards/accessories/wings_rainbow.md`
- `assets/images/rewards/badges/badge_10_correct.md`
- `assets/images/rewards/badges/badge_level_complete.md`
- `assets/images/rewards/stickers/sticker_rainbow.md`
- `assets/images/rewards/stickers/sticker_unicorn.md`

Clasificacion aplicada:

- Resolver con Flutter/iconos/librerias si se usan como recompensa simple:
  - `assets/images/rewards/badges/badge_10_correct.md`
  - `assets/images/rewards/badges/badge_level_complete.md`
  - `assets/images/rewards/stickers/sticker_rainbow.md`
  - `assets/images/rewards/stickers/sticker_unicorn.md`
- Renderizar con fallback Flutter por ahora; convertir a asset ilustrado solo si van a ser accesorios equipables o premios grandes:
  - `assets/images/rewards/accessories/magic_wand.md`
  - `assets/images/rewards/accessories/necklace_star.md`
  - `assets/images/rewards/accessories/wings_rainbow.md`
