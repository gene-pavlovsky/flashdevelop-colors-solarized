#!/bin/sh
#
# themegen.sh: generates theme files from a set of templates and sed scripts, and packages them for import into FlashDevelop

SOLARIZE_DARK="./solarize.sh -s"
SOLARIZE_LIGHT="./solarize.sh -s -l -H"
SOLARIZE_SYNTAX_OPTS="-q -c"
SOLARIZE_THEME_OPTS=

COMMON_PRE="templates/common-pre.sed"
COMMON_POST="templates/common-post.sed"
SYNTAX_PRE="templates/syntax-pre.sed"
SYNTAX_POST="templates/syntax-post.sed"
THEME_PRE="templates/theme-pre.sed"
THEME_POST="templates/theme-post.sed"

ZIP="7z a -tzip"
BASE_DIR="\$(BaseDir)"
SYNTAX_DIR="$BASE_DIR/Settings/Languages"
THEME_DIR="$BASE_DIR/Settings/Themes"

mkdir dark light 2>/dev/null

echo "Syntax:"
$SOLARIZE_DARK $SOLARIZE_SYNTAX_OPTS >dark/syntax-solarize.sed
$SOLARIZE_LIGHT $SOLARIZE_SYNTAX_OPTS >light/syntax-solarize.sed
for file in templates/*.xml*; do
	outfile=${file:10}
	echo "  $outfile"
	sed -f $COMMON_PRE -f $SYNTAX_PRE -f templates/syntax-dark.sed -f dark/syntax-solarize.sed -f $SYNTAX_POST -f $COMMON_POST "$file" >dark/"$outfile"
	sed -f $COMMON_PRE -f $SYNTAX_PRE -f templates/syntax-light.sed -f light/syntax-solarize.sed -f $SYNTAX_POST -f $COMMON_POST "$file" >light/"$outfile"
done
echo

echo "Themes:"
$SOLARIZE_DARK $SOLARIZE_THEME_OPTS >dark/theme-solarize.sed
$SOLARIZE_LIGHT $SOLARIZE_THEME_OPTS >light/theme-solarize.sed
echo "  SolarizedDark.fdi"
sed -f $COMMON_PRE -f $THEME_PRE -f templates/theme-dark.sed -f dark/theme-solarize.sed -f $THEME_POST -f $COMMON_POST templates/Solarized.fdi >dist/SolarizedDark.fdi
echo "  SolarizedLight.fdi"
sed -f $COMMON_PRE -f $THEME_PRE -f templates/theme-light.sed -f light/theme-solarize.sed -f $THEME_POST -f $COMMON_POST templates/Solarized.fdi >dist/SolarizedLight.fdi

echo
echo "Packaging themes:"

package_theme() {
	echo "$1:"
	rm -rf "$BASE_DIR"
	mkdir -p "$SYNTAX_DIR"
	cp ../${1,,}/*.xml* "$SYNTAX_DIR"
	rm -f SyntaxThemes/Solarized$1.fdz
	$ZIP SyntaxThemes/Solarized$1.fdz "$BASE_DIR"
	echo
	mkdir -p "$THEME_DIR"
	cp Solarized$1.fdi "$THEME_DIR"
	cp Solarized$1.fdi "$THEME_DIR/CURRENT"
	rm -f FullThemes/Solarized$1.fdz
	$ZIP FullThemes/Solarized$1.fdz "$BASE_DIR"
	rm -rf "$BASE_DIR"
	echo
}

package_theme_set() {
	echo "Themes set:"
	rm -rf "$BASE_DIR"
	mkdir -p "$THEME_DIR"
	cp -a FullThemes SyntaxThemes *.fdi "$THEME_DIR"
	$ZIP SolarizedThemes.fdz "$BASE_DIR"
	rm -rf "$BASE_DIR"
	echo
}

cd dist
package_theme Dark
package_theme Light
package_theme_set
cd ..

echo -n "Cleaning up... "
rm -rf dark light
echo "done"
