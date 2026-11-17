#!/usr/bin/env bash
set -euo pipefail

usage() {
	echo "usage: $(basename "$0") [--palette <dir>] <scheme.yaml>" >&2
	echo "print the monkeytype custom theme share url of a base16 or base24 scheme" >&2
	echo "with --palette, write one swatch svg per color into <dir> and print an html table of them instead" >&2
	exit 1
}

palette_dir=
if [[ ${1-} == --palette ]]; then
	[[ $# -ge 2 ]] || usage
	palette_dir=$2
	shift 2
fi
[[ $# -eq 1 ]] || usage

theme=$(yq -o=json '(.. | select(tag == "!!int" or tag == "!!float")) tag = "!!str" | .palette // .' "$1" | jq '
	def color($key): (.[$key] // error("scheme has no \($key)")) | tostring | "#" + ltrimstr("#");
	def color($key; $fallback): if .[$key] != null then color($key) else color($fallback) end;

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
')

if [[ -z $palette_dir ]]; then
	jq -r '{c: [.[]]} | tojson | @base64 | @uri "https://monkeytype.com?customTheme=\(.)"' <<<"$theme"
	exit
fi

mkdir -p "$palette_dir"
while IFS= read -r -d '' slot && IFS= read -r -d '' svg; do
	printf '%s\n' "$svg" >"$palette_dir/$slot.svg"
done < <(jq --raw-output0 '
	. as $theme
	| to_entries[]
	| .key as $slot
	| .value as $box
	| (if $slot == "bg" or $slot == "subAlt" then $theme.text else $theme.bg end) as $text_color
	| $slot,
		([
			"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"84\" height=\"28\" viewBox=\"0 0 84 28\">",
			"<rect width=\"84\" height=\"28\" rx=\"6\" fill=\"\($box)\"/>",
			"<text x=\"42\" y=\"14\" fill=\"\($text_color)\" font-family=\"monospace\" font-size=\"14\" text-anchor=\"middle\" dominant-baseline=\"central\">\($box)</text>",
			"</svg>"
		] | join("\n"))
' <<<"$theme")

jq -r --arg dir "$palette_dir" '
	. as $theme
	| def cell: .[0] as $slot | .[1] as $label | $theme[$slot] as $hex
		| "<td>\($label)</td>",
			"<td><code>\($hex)</code></td>",
			"<td><img src=\"\($dir)/\($slot).svg\" alt=\"\($hex)\"></td>";
	[
		["bg", "background"], ["main", "main"],
		["sub", "sub"], ["text", "text"],
		["caret", "caret"], ["subAlt", "sub alt"],
		["error", "error"], ["errorExtra", "extra error"],
		["colorfulError", "colorful error"], ["colorfulErrorExtra", "colorful extra error"]
	]
	| "<table id=\"palette\">",
		(range(0; length; 2) as $row_start | .[$row_start:$row_start + 2] | "<tr>", (.[] | cell), "</tr>"),
		"</table>"
' <<<"$theme"
