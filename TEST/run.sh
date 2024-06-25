#!/bin/sh
set -x
../sprout --read-png sprite.png 1 1 --binarize 128 --write-png binary_sprite.png --write-c sprite.c 24 21
../sprout --read-png sprite.png 1 1 --binarize 128 --invert --write-png inverted_binary_sprite.png --write-c inverted_sprite.c 24 21
../sprout --read-png trimmed_sprite.png 1 1 --binarize 128 --write-png binary_trimmed_sprite.png --trim --write-c trimmed_sprite.c 24 21
../sprout --read-png four_color_sprite.png 2 1 --read-palette-png four_color_palette.png --write-c four_color_sprite.c 24 21
../sprout --read-png font.png 1 1 --binarize 128 --tile 4 8 --write-png tiled_font_1.png --tile -2 -4 --write-png tiled_font_2.png --write-flat-c flat_font.c 8 4
