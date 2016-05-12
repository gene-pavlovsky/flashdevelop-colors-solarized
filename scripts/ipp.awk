#!/bin/awk -f
#
# A minimalistic preprocessor.
#
# Command-line options:
#   -DNAME    defines the specified name
#
# TODO: Add error checking and support for nested (recursive) conditional blocks.
#
# Supported directives:
#   #include "filename"
#     Includes the contents of the specified file, indenting them according to the indent level of the #include directive.
#     Nested (recursive) includes are supported.
#   #define NAME
#     Defines the specified name.
#   #undef NAME
#     Undefines the specified name.
#   #ifdef NAME
#     If the specified name is defined, includes the following section until the next #else or #endif directive.
#   #ifndef NAME
#     If the specified name is not defined, includes the following section until the next #else or #endif directive.
#   #else
#     Inverts the last #ifdef or #ifndef directive - respectfully omits or includes the following section until the next #endif directive.
#   #endif
#     Ends the conditional block started by the last #ifdef or #ifndef directive.
#   #warning
#     Outputs a warning to stderr.
#   #error
#     Outputs an error to stderr, and exits with an error code of 2.
#

function msg(message, exit_code) {
	# TODO: Display current filename and line number (process_line() must use a stack to keep track of them).
	print message >> "/dev/stderr"
	if ((exit_code != "") && (exit_code >= 0))
		exit exit_code
}

function die(message, exit_code) {
	msg(message, (exit_code != "") ? exit_code : 1)
}

function include_file(indent,    filename, i) {
	filename=gensub(/^[[:space:]]*#include[[:space:]]+("([^"]*)"|([^ "]*))|.*$/, "\\2\\3", 1)
	if (!filename)
		die("Invalid include: \"" $0 "\".")
	while ((i = (getline <filename)) > 0)
		process_line(indent)
	if (i == -1)
		die("Missing include file: \"" filename "\".")
	close(filename)
}

function process_line(indent) {
	if (active) {
		if ($1 == "#include")
			include_file(indent gensub(/^([[:space:]]*).*/, "\\1", 1))
		else if ($1 == "#define")
			defines[$2] = 1
		else if ($1 == "#undef")
			delete defines[$2]
		else if ($1 == "#ifdef")
			active = defines[$2]
		else if ($1 == "#ifndef")
			active = !defines[$2]
		else if ($1 == "#else")
			active = 0
		else if ($1 == "#endif")
			;
		else if ($1 == "#warning")
			msg("warning: " gensub(/^[[:space:]]*#warning[[:space:]]*/, "", 1));
		else if ($1 == "#error")
			die("error: " gensub(/^[[:space:]]*#error[[:space:]]*/, "", 1));
		else
			print indent $0
	}
	else {
		if (($1 == "#else") || ($1 == "#endif"))
			active = 1
	}
}

BEGIN {
	for (i = 0; i < ARGC; ++i) {
		if (ARGV[i] == "--") {
			ARGV[i] = ""
			break
		}
		else if (ARGV[i] ~ /^-D/) {
			defines[substr(ARGV[i], 3)] = 1
			ARGV[i] = ""
		}
	}
	active = 1
}

{
	process_line("")
}
