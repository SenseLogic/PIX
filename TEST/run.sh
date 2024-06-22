#!/bin/sh
set -x
../sprout sprite.png
../sprout --trim trimmed_sprite.png
../sprout --invert trimmed_sprite.png inverted_sprite.c
