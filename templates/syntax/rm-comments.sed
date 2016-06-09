#!/bin/sed -f
#
# Syntax Coloring (remove comments)
#

# Remove single-line comments.
/^\s*<!--.*-->\s*$/ d
s/<!--.*-->//g

# Remove multi-line comments.
/^\s*<!--/,/-->/ d
