#!/bin/sh
dir=$(dirname "$0")
for file in *.xml; do
	"$dir"/xml_to_override.awk "$file" >"$file".override
done
