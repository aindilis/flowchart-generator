#!/bin/sh

dot -Tpng flp2.dot -o flp2.png

./persective4.pl

xdg-open flp2-p.png
