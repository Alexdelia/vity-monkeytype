fresh_dir_with_palette() {
	cd "$(mktemp -d)" || exit
	mkdir palette
	touch palette/planted
}

refuses() {
	local scenario=$1
	if update-generated >/dev/null 2>&1; then
		echo "$scenario: update-generated succeeded" >&2
		return 1
	fi
	if [[ ! -f palette/planted ]]; then
		echo "$scenario: palette/ replaced" >&2
		return 1
	fi
}

(
	fresh_dir_with_palette
	refuses "no README.md"
)

(
	fresh_dir_with_palette
	printf '%s\n' '<table id="palette">' '</table>' >README.md
	refuses "no share url"
)

(
	fresh_dir_with_palette
	printf '%s\n' 'https://monkeytype.com?customTheme=x' '  <table id="palette">' '</table>' >README.md
	refuses "indented table"
)

(
	fresh_dir_with_palette
	printf '%s\n' 'https://monkeytype.com?customTheme=x' '<table id="palette">' >README.md
	refuses "unclosed table"
)

(
	fresh_dir_with_palette
	printf '%s\n' 'https://monkeytype.com?customTheme=x' '<table>' '</table>' >README.md
	refuses "table without palette id"
)
