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
--color-palette palette.png
--image-column-count 1
--image-row-count 1
--pixel-minimum-lightness 128
--invert-lightness
--sprite-column-count 24
--sprite-row-count 21
--trim-blank-rows
```

### Examples

```bash
sprout sprite.png
```

```bash
sprout sprite.png sprite.c
```

```bash
sprout --palette palette.png sprite.png sprite.c
```

```bash
sprout --pixel-minimum-lightness 128 sprite.png
```

```bash
sprout --pixel-minimum-lightness 128 --sprite-column-count 24 --sprite-row-count 21 sprite.png sprite.c
```

```bash
sprout --pixel-minimum-lightness 128 --sprite-column-count 24 --sprite-row-count 21 --invert-lightness --trim sprite.png sprite.c
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
