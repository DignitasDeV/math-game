# Asset TODO

Recopilatorio creado desde `agent_docs`.

Cada placeholder `.md` usa el nombre base del asset final. Dentro indica la extension final esperada, el uso y una descripcion para generar o buscar el asset correcto.

Regla:

- IA generativa: personajes, fondos, objetos narrativos, recompensas especiales y pegatinas.
- Flutter/librerias: iconos funcionales, botones, paneles y controles de UI en MVP.
- Packs externos: solo si se quiere sustituir el aspecto de UI por un pack coherente y con licencia clara.

## Imagenes IA

- `assets/images/characters/unicorn_female/`: `idle.webp`, `happy.webp`, `thinking.webp`, `celebrating.webp`, `encouraging.webp`
- `assets/images/characters/unicorn_male/`: `idle.webp`, `happy.webp`, `thinking.webp`, `celebrating.webp`, `encouraging.webp`
- `assets/images/backgrounds/`: `heart_forest.webp`, `star_lake.webp`, `rainbow_path.webp`, `crystal_castle.webp`, `magic_tower.webp`, `home_background.webp`, `map_background.webp`
- `assets/images/items/`: `heart_pink.webp`, `star_yellow.webp`, `flower_blue.webp`, `gem_purple.webp`, `cloud_white.webp`, `cupcake_pink.webp`, `ten_block.webp`, `unit_cube.webp`
- `assets/images/rewards/accessories/`: `crown_pink.webp`, `bow_heart.webp`, `wings_rainbow.webp`, `magic_wand.webp`, `necklace_star.webp`
- `assets/images/rewards/stickers/`: `sticker_heart.webp`, `sticker_star.webp`, `sticker_unicorn.webp`, `sticker_rainbow.webp`
- `assets/images/rewards/badges/`: `badge_first_sum.webp`, `badge_10_correct.webp`, `badge_subtraction_beginner.webp`, `badge_level_complete.webp`

## Assets de packs o librerias

Para MVP, estos se implementan preferiblemente con `Icons`, `material_symbols_icons`, `font_awesome_flutter`, `FilledButton`, `Card`, `Container` y tema centralizado. Los `.svg`/`.webp` solo se usan si se decide incorporar un pack externo.

- `assets/images/ui/`: `icon_speaker.svg`, `icon_home.svg`, `icon_settings.svg`, `icon_replay.svg`, `icon_continue.svg`, `icon_hint.svg`, `icon_lock.svg`, `icon_check.svg`, `icon_close.svg`, `icon_star.svg`, `icon_heart.svg`, `icon_trophy.svg`
- `assets/images/ui/panels/`: `panel_small.webp`, `panel_medium.webp`, `panel_large.webp`
- `assets/images/ui/buttons/`: `button_primary.webp`, `button_secondary.webp`

## Animaciones

- `assets/animations/`: `confetti.json`, `sparkle_burst.json`, `reward_unlock.json`, `success_star.json`, `magic_loading.json`

## Audio

SFX en `.wav`. Musica en `.mp3`.

- `assets/audio/sfx/ui/`: `tap_01.wav`, `back_01.wav`
- `assets/audio/sfx/feedback/`: `correct_01.wav`, `wrong_soft_01.wav`, `hint_open_01.wav`
- `assets/audio/sfx/rewards/`: `sparkle_01.wav`, `reward_unlock_01.wav`, `level_complete_01.wav`, `sticker_collected_01.wav`
- `assets/audio/music/`: `happy_magic_loop_01.mp3`, `calm_rainbow_loop_01.mp3`
- `assets/audio/voice/es/`: `well_done_01.mp3`, `try_again_01.mp3`, `lets_count_01.mp3`
- `assets/audio/voice/ca/`: `molt_be_01.mp3`, `torna_ho_a_provar_01.mp3`, `comptem_juntes_01.mp3`

## Licencias

- `assets/licenses/image_generation_notes.md`
- `assets/licenses/audio_licenses.md`
- `assets/licenses/icon_licenses.md`
- `assets/licenses/animation_licenses.md`
