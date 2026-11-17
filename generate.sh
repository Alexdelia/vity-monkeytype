#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
	echo "usage: $(basename "$0") <scheme.yaml>" >&2
	echo "print the monkeytype custom theme share url of a base16 or base24 scheme" >&2
	exit 1
fi

yq -o=json '.palette // .' "$1" | jq -r '
	def color($key): (.[$key] // error("scheme has no \($key)")) | tostring | "#" + ltrimstr("#");
	def color($key; $fallback): if has($key) then color($key) else color($fallback) end;

	{
		bg: color("base00"),
		main: color("base0E"),
		caret: color("base06"),
		sub: color("base04"),
		subAlt: color("base01"),
		text: color("base05"),
		error: color("base08"),
		errorExtra: color("base0F"),
		colorfulError: color("base12"; "base08"),
		colorfulErrorExtra: color("base08")
	}
	| {c: [.[]]}
	| tojson
	| @base64
	| @uri "https://monkeytype.com?customTheme=\(.)"
'
