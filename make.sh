#!/bin/sh
set -x
dmd -m64 pix.d color.d png.d
rm *.o
