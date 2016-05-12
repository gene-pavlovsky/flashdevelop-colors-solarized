#!/bin/sh
#
# gen-themes.sh: generates theme files from a set of templates and sed scripts, and packages them for import into FlashDevelop

usage() {
	{
		echo "Usage: "$(basename "$0")" [options]"
		echo
		echo "Options:"
		echo -e "      --help\t\tprint this help, then exit"
		echo -e "  -c, --comments\tkeep comments in the generated theme files (default is to strip them)"
		echo -e "  -d, --docs\t\tgenerate docs (implies --keep-comments)"
	} >&2
	exit 2
}

while test $# -gt 0; do
	case $1 in
		--help)
			usage
		;;
		-c|--comments)
			comments=1
		;;
		-d|--docs)
			comments=1
			docs=1
		;;
		-?*)
			echo "unrecognized option \"$1\"" >&2
			exit 1
		;;
	esac
	
	shift
done

# **********************************************************************************************************************
# Constants
#

SOLARIZE_DARK="./solarized/solarize.sh -s"
SOLARIZE_LIGHT="./solarized/solarize.sh -s -l -H"
SOLARIZE_SYNTAX_OPTS="-q -c"
SOLARIZE_THEME_OPTS=

BASE_PATH=$(realpath $(dirname "$0"))
SRC_PATH="templates"

SYNTAX_PATH="$SRC_PATH/syntax"
SYNTAX_PRE="$SYNTAX_PATH/pre.sed"
SYNTAX_DARK="$SYNTAX_PATH/dark.sed"
SYNTAX_LIGHT="$SYNTAX_PATH/light.sed"
SYNTAX_POST="$SYNTAX_PATH/post.sed"
THEME_PATH="$SRC_PATH/theme"
THEME_PRE="$THEME_PATH/pre.sed"
THEME_DARK="$THEME_PATH/dark.sed"
THEME_LIGHT="$THEME_PATH/light.sed"
THEME_POST="$THEME_PATH/post.sed"

if test -z "$comments"; then
	SYNTAX_RMC="$SYNTAX_PATH/rm-comments.sed"
	THEME_RMC="$THEME_PATH/rm-comments.sed"
else
	SYNTAX_RMC=/dev/null
	THEME_RMC=/dev/null
fi

INCLUDE_PP="scripts/ipp.awk"
SQUEEZE="scripts/cat-s.sed"

ZIP="7z a -tzip -xr!*.tmp"
BASE_DIR="\$(BaseDir)"
SYNTAX_DIR="$BASE_DIR/Settings/Languages"
THEME_DIR="$BASE_DIR/Settings/Themes"

# **********************************************************************************************************************
# Functions
#

error() {
	{
		test "$1" && echo -e "Error during: $@" || echo -e "Error"
	} >&2
	exit 1
}
set -o pipefail

gen_syntax() {
	eval local syntax='${SYNTAX_'${1^^}'}'
	{
		echo '<!-- COLORING_START -->'
		(cd $SYNTAX_PATH && exec awk -f "$BASE_PATH/$INCLUDE_PP" "$BASE_PATH/$2") | sed -f $SYNTAX_PRE -f $syntax -f $SYNTAX_POST -f $1/solarize.sed -f $SYNTAX_RMC | sed -f $SQUEEZE || error syntax-$1: "$3"
		echo -n '<!-- COLORING_END -->'
	} >"$1/$3"
}

gen_theme() {
	echo "  Solarized${1^}.fdi"
	eval local theme='${THEME_'${1^^}'}'
	sed -f $THEME_PRE -f $theme -f $THEME_POST -f $1/solarize.sed -f $THEME_RMC $THEME_PATH/theme.fdi | sed -f $SQUEEZE >dist/Solarized$1.fdi || error theme-$1
}

package_theme() {
	local title=${1^}
	echo "$title:"
	rm -rf "$BASE_DIR"
	mkdir -p "$SYNTAX_DIR"
	cp ../$1/*.xml.override "$SYNTAX_DIR"
	rm -f SyntaxThemes/Solarized$title.fdz
	$ZIP SyntaxThemes/Solarized$title.fdz "$BASE_DIR" || error zip-syntax: $1
	echo
	mkdir -p "$THEME_DIR"
	cp Solarized$title.fdi "$THEME_DIR"
	cp Solarized$title.fdi "$THEME_DIR/CURRENT"
	rm -f FullThemes/Solarized$title.fdz
	$ZIP FullThemes/Solarized$title.fdz "$BASE_DIR" || error zip-theme: $1
	rm -rf "$BASE_DIR"
	echo
}

package_theme_set() {
	echo "Themes set:"
	rm -rf "$BASE_DIR"
	mkdir -p "$THEME_DIR"
	cp -a FullThemes SyntaxThemes *.fdi "$THEME_DIR"
	rm -f SolarizedThemes.fdz
	$ZIP SolarizedThemes.fdz "$BASE_DIR" || error zip-themes
	rm -rf "$BASE_DIR"
	echo
}

# **********************************************************************************************************************
# Body
#

mkdir dark light 2>/dev/null

echo "Syntax:"
$SOLARIZE_DARK $SOLARIZE_SYNTAX_OPTS >dark/solarize.sed
$SOLARIZE_LIGHT $SOLARIZE_SYNTAX_OPTS >light/solarize.sed
for file in $SYNTAX_PATH/*.xml.override; do
	outfile=${file:$((${#SYNTAX_PATH}+1))}
	echo "  $outfile"
	gen_syntax dark "$file" "$outfile"
	test -z "$docs" && gen_syntax light "$file" "$outfile"
done
echo

echo "Themes:"
$SOLARIZE_DARK $SOLARIZE_THEME_OPTS >dark/solarize.sed
$SOLARIZE_LIGHT $SOLARIZE_THEME_OPTS >light/solarize.sed
gen_theme dark
test -z "$docs" && gen_theme light
echo

if test -z "$docs"; then
	echo "Packaging themes:"
	cd dist
	package_theme dark
	package_theme light
	package_theme_set
	cd ..
else
	echo -n "Copying docs... "
	mkdir -p doc/syntax 2>/dev/null
	cp dist/SolarizedDark.fdi doc/theme.fdi
	rm -f doc/syntax/*.xml.override
	cp dark/*.xml.override doc/syntax
	echo -e "done\n"
fi

echo -n "Cleaning up... "
rm -rf dark light
echo "done"
