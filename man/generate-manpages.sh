#!/bin/sh
pandoc -s -f markdown -t man dcaenc.md | sed 's| \"\" \"\"$| \"v2\"|' > dcaenc.1
pandoc -s -f markdown -t man libdcaenc.md | sed 's| \"\" \"\"$| \"v2\"|' > libdcaenc.3
