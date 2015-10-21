#!/bin/awk -f
#
# include_pp.awk: a primitive #include preprocessor

{
	if (($1 == "#include") && (NF == 2)) {
		prefix = $0
		sub(/[^ \t].*/, "", prefix)
		filename = $2
		gsub(/"/, "", filename)
		while ((i = getline include_line < filename) == 1) {
			print prefix include_line
		}
		if (i == -1) {
			print "Missing include file: " filename
			exit 1
		}
	}
	else {
		print
	}
}
