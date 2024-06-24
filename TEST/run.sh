#!/bin/sh
set -x
../sprout sprite.png
../sprout --trim-blank-rows trimmed_sprite.png
../sprout --invert-lightness trimmed_sprite.png inverted_sprite.c
../sprout --invert-lightness trimmed_sprite.png inverted_sprite.c
../sprout --color-palette four_color_palette.png --image-column-step 2 four_color_sprite.png
