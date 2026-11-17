url=$(generate "$1")
encoded=${url#https://monkeytype.com?customTheme=}
colorful_error=$(printf '%b' "${encoded//%/\\x}" | base64 -d | jq -r '.c[8]')

if [[ $colorful_error != "#d32f2f" ]]; then
	echo "colorfulError: expected base08 #d32f2f, got $colorful_error" >&2
	exit 1
fi
