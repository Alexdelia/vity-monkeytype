cd "$(mktemp -d)" || exit

other_table=$(printf '%s\n' '<table>' '<tr><td>unrelated</td></tr>' '</table>')

printf '%s\n' \
	'https://monkeytype.com?customTheme=stale' \
	'<table id="palette">' \
	'<tr><td>stale</td></tr>' \
	'</table>' \
	'' \
	"$other_table" >README.md

update-generated

fail() {
	echo "$1" >&2
	cat README.md >&2
	exit 1
}

rg -qUF "$other_table" README.md || fail "unrelated table changed"
rg -qF 'stale' README.md && fail "stale palette table or share url kept"
rg -qF 'palette/bg.svg' README.md || fail "palette table not regenerated"
[[ -f palette/bg.svg ]] || fail "palette/ not written"
