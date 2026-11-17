scheme=$1

url=$(generate "$scheme")
encoded=${url#https://monkeytype.com?customTheme=}
actual=$(printf '%b' "${encoded//%/\\x}" | base64 -d | jq -c .)
expected='{"c":["#000000","#0000ee","#666666","#100000","#010101","#123e45","#0e0808","#1e10ff","#0e0808","#0e0808"]}'

if [[ $actual != "$expected" ]]; then
	echo "expected: $expected" >&2
	echo "actual:   $actual" >&2
	exit 1
fi
