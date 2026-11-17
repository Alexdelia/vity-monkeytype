rm -rf palette
cp -r --no-preserve=mode "$VITY_PALETTE/palette" palette

sed -i -E "s|https://monkeytype\.com\?customTheme=[A-Za-z0-9%]*|$(cat "$VITY_URL")|g" README.md

awk -v table="$VITY_PALETTE/table.html" '
	/^<table>$/ { while ((getline line < table) > 0) print line; skipping = 1 }
	!skipping { print }
	/^<\/table>$/ { skipping = 0 }
' README.md >README.md.tmp
mv README.md.tmp README.md
