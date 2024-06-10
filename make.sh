#!/bin/sh
set -x
dmd -m64 sprout.d color.d png.d
rm *.o
