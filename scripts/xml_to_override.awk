#!/bin/awk -f
#
# xml_to_override.awk: helper script for xml_to_override.sh

/COLORING_START/ { 
	output=1
	num_tabs = gsub(/\t/, "")
}

{
	if (output) {
		for (i = 0; i < num_tabs; ++i)
			sub(/^\t/, "")
		gsub(/\t+/, "\t")
		print $0
	}
}

/COLORING_END/ { 
	exit 0 
}
