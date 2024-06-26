![](https://github.com/senselogic/SPROUT/blob/master/LOGO/sprout.png)

# Sprout

Sprite converter.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 sprout.d color.d png.d
```

## Command line

```bash
sprout [options]
```

### Options

```bash
--read-palette-png palette.png
--read-png sprite.png column_step row_step
--binarize threshold
--invert
--tile tile_column_count tile_row_count
--flatten column_count
--trim
--write-c sprite.c sprite_column_count sprite_row_count
```

### Examples

```bash
sprout --read-png sprite.png 1 1 --binarize 128 --write-c sprite.c 24 21
```

```bash
sprout --read-png sprite.png 1 1 --binarize 128 --invert --write-c inverted_sprite.c 24 21
```

```bash
sprout --read-png sprite.png 1 1 --binarize 128 --trim --write-c trimmed_sprite.c 24 21
```

```bash
sprout --read-png four_color_sprite.png 2 1 --read-palette-png four_color_palette.png --write-c four_color_sprite.c 24 21
```

```bash
sprout --read-png font.png 1 1 --binarize 128 --tile 4 8 --write-png tiled_font_1.png --tile -2 -4 --write-png tiled_font_2.png --flatten 32 --write-png flat_font.png --write-c font.c 0 0
```

## Dependencies

*   [ARSD PNG library](https://github.com/adamdruppe/arsd)

## Limitations

Only supports PNG files.

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
