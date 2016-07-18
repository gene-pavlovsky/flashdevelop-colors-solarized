#!/bin/awk -f
#
# Helper script for xml_to_override.sh.
#

/COLORING_END/ {
	exit 0
}

{
	if (output) {
		for (i = 0; i < num_tabs; ++i)
			sub(/^\t/, "")
		gsub(/\t+/, "\t")
		print $0
	}
}

/COLORING_START/ {
	output=1
	num_tabs = gsub(/\t/, "")
}
