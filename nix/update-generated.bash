if ! rg -q --no-messages 'https://monkeytype\.com\?customTheme=' README.md ||
	! rg -qFx --no-messages '<table id="palette">' README.md ||
	! rg -qFx --no-messages '</table>' README.md; then
	echo "update-generated: no README.md with share url and <table id=\"palette\">...</table> in $PWD, run from repo root" >&2
	exit 1
fi

rm -rf palette
cp -r --no-preserve=mode "$VITY_PALETTE/palette" palette

sed -i -E "s|https://monkeytype\.com\?customTheme=[A-Za-z0-9%]*|$(cat "$VITY_URL")|g" README.md

sed -i \
	-e '/^<table id="palette">$/,/^<\/table>$/{' \
	-e "/^<\/table>$/r $VITY_PALETTE/table.html" \
	-e 'd' \
	-e '}' \
	README.md
