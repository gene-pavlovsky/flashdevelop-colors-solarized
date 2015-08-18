#!/bin/sh
SUB="./solarized_sub.sh"
DARK_OPTIONS=""
LIGHT_OPTIONS="-l -H"

ZIP="7z a -tzip"
BASE_DIR="\$(BaseDir)"
SYNTAX_DIR="$BASE_DIR/Settings/Languages"
THEME_DIR="$BASE_DIR/Settings/Themes"

mkdir dark light 2>/dev/null

echo "Syntax:"
for file in templates/*.xml*; do
	outfile=${file:10}
	echo "  $outfile"
  "$SUB" $DARK_OPTIONS "$file" >dark/"$outfile"
  "$SUB" $LIGHT_OPTIONS "$file" >light/"$outfile"
done
echo

echo "Themes:"
echo "  SolarizedDark.fdi"
sed -e 's,{solarized},SolarizedDark,' \
		-e 's,{image_set},Darker,' \
		templates/Solarized.fdi | "$SUB" $DARK_OPTIONS -n - >dist/SolarizedDark.fdi

echo "  SolarizedLight.fdi"
sed -e 's,{solarized},SolarizedLight,' \
		-e 's,{image_set},Default,' \
		templates/Solarized.fdi | "$SUB" $LIGHT_OPTIONS -n - >dist/SolarizedLight.fdi

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

cd dist
package_theme Dark
package_theme Light
cd ..

echo -n "Cleaning up... "
rm -rf dark light
echo "done"
