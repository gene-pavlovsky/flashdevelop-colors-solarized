#!/bin/sh
#
# Reads all xml files in a directory containing FlashDevelop syntax coloring xml files, strips everything but the coloring settings, outputs to .override files.   
#

dir=$(dirname "$0")
for file in *.xml; do
	"$dir"/xml_to_override.awk "$file" >"$file".override
done
