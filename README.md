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
sprout [options] sprite.png [sprite.c]
```

### Options

```bash
--pixel-minimum-lightness pixel_minimum_lightness
--sprite-column-count sprite_column_count
--sprite-row-count sprite_row_count
```

### Examples

```bash
sprout sprite.png
```

```bash
sprout sprite.png sprite.c
```

```bash
sprout --pixel-minimum-lightness 128 sprite.png
```

```bash
sprout --pixel-minimum-lightness 128 --sprite-column-count 24 --sprite-row-count 21 sprite.png sprite.c
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
