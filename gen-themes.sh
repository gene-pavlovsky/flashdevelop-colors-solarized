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

INCLUDE_PP="scripts/include_pp.awk"
SQUEEZE="scripts/cat-s.sed"

ZIP="7z a -tzip"
BASE_DIR="\$(BaseDir)"
SYNTAX_DIR="$BASE_DIR/Settings/Languages"
THEME_DIR="$BASE_DIR/Settings/Themes"

error() {
	test "$1" && echo -e "Error during: $@" || echo -e "Error"
	exit 1
}
set -o pipefail

mkdir dark light 2>/dev/null

echo "Syntax:"
$SOLARIZE_DARK $SOLARIZE_SYNTAX_OPTS >dark/solarize.sed
$SOLARIZE_LIGHT $SOLARIZE_SYNTAX_OPTS >light/solarize.sed
for file in $SYNTAX_PATH/*.xml.override; do
	outfile=${file:$((${#SYNTAX_PATH}+1))}
	echo "  $outfile"
	(cd $SYNTAX_PATH && exec awk -f "$BASE_PATH/$INCLUDE_PP" "$BASE_PATH/$file") | sed -f $SYNTAX_RMC -f $SYNTAX_PRE -f $SYNTAX_DARK -f dark/solarize.sed -f $SYNTAX_POST | sed -f $SQUEEZE >dark/"$outfile" || error syntax-dark: "$outfile"
	(cd $SYNTAX_PATH && exec awk -f "$BASE_PATH/$INCLUDE_PP" "$BASE_PATH/$file") | sed -f $SYNTAX_RMC -f $SYNTAX_PRE -f $SYNTAX_LIGHT -f light/solarize.sed -f $SYNTAX_POST | sed -f $SQUEEZE >light/"$outfile" || error syntax-light: "$outfile"
done
echo
 
echo "Themes:"
$SOLARIZE_DARK $SOLARIZE_THEME_OPTS >dark/solarize.sed
$SOLARIZE_LIGHT $SOLARIZE_THEME_OPTS >light/solarize.sed
echo "  SolarizedDark.fdi"
sed -f $THEME_RMC -f $THEME_PRE -f $THEME_DARK -f dark/solarize.sed -f $THEME_POST $THEME_PATH/theme.fdi | sed -f $SQUEEZE >dist/SolarizedDark.fdi || error theme-dark
echo "  SolarizedLight.fdi"
sed -f $THEME_RMC -f $THEME_PRE -f $THEME_LIGHT -f light/solarize.sed -f $THEME_POST $THEME_PATH/theme.fdi | sed -f $SQUEEZE >dist/SolarizedLight.fdi || error theme-light
echo

package_theme() {
	echo "$1:"
	rm -rf "$BASE_DIR"
	mkdir -p "$SYNTAX_DIR"
	cp ../${1,,}/*.xml.override "$SYNTAX_DIR"
	rm -f SyntaxThemes/Solarized$1.fdz
	$ZIP SyntaxThemes/Solarized$1.fdz "$BASE_DIR" || error zip-syntax: ${1,,}
	echo
	mkdir -p "$THEME_DIR"
	cp Solarized$1.fdi "$THEME_DIR"
	cp Solarized$1.fdi "$THEME_DIR/CURRENT"
	rm -f FullThemes/Solarized$1.fdz
	$ZIP FullThemes/Solarized$1.fdz "$BASE_DIR" || error zip-theme: ${1,,}
	rm -rf "$BASE_DIR"
	echo
}

package_theme_set() {
	echo "Themes set:"
	rm -rf "$BASE_DIR"
	mkdir -p "$THEME_DIR"
	cp -a FullThemes SyntaxThemes *.fdi "$THEME_DIR"
	$ZIP SolarizedThemes.fdz "$BASE_DIR" || error zip-themes
	rm -rf "$BASE_DIR"
	echo
}

if test -z "$docs"; then
	echo "Packaging themes:"
	cd dist
	package_theme Dark
	package_theme Light
	package_theme_set
	cd ..
else
	echo -n "Copying docs... "
	cp dist/SolarizedDark.fdi doc/theme.fdi
	cp dark/*.xml.override doc/syntax
	echo -e "done\n"
fi

echo -n "Cleaning up... "
rm -rf dark light
echo "done"
