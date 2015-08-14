#!/bin/sh

SUB="./solarized_sub.sh"
DARK_OPTIONS=""
LIGHT_OPTIONS="-l -H"

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
		templates/Solarized.fdi | "$SUB" $DARK_OPTIONS -n - >dark/SolarizedDark.fdi
rm -f dark/CURRENT
ln dark/SolarizedDark.fdi dark/CURRENT

echo "  SolarizedLight.fdi"
sed -e 's,{solarized},SolarizedLight,' \
		-e 's,{image_set},Default,' \
		templates/Solarized.fdi | "$SUB" $LIGHT_OPTIONS -n - >light/SolarizedLight.fdi
rm -f light/CURRENT
ln light/SolarizedLight.fdi light/CURRENT
