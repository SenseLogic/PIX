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
sprout image.png sprites.c
```

### Examples

```bash
sprout image.png sprites.c
```

## Dependencies

*   [ARSD PNG library](https://github.com/adamdruppe/arsd)

## Limitations

Only supports PNG files.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
