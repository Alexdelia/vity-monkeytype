outside_string='(?:[^"\x27\n]|"(?:[^"\\\n]|\\.)*"|\x27[^\x27\n]*\x27)*'
status=0
for file in "$@"; do
	case "$file" in
	*.nix) pattern="^\\s*(#|/\\*)|^$outside_string\\s(#|/\\*)" ;;
	*.sh | *.bash | *.yml | *.yaml) pattern="^\\s*#|^$outside_string\\s#" ;;
	*) continue ;;
	esac
	if rg --line-number --with-filename "$pattern" "$file" |
		rg --invert-match '^[^:]+:1:#!' |
		rg --invert-match '^[^:]+:[0-9]+:\s*#\s*<?https?://\S+>?\s*$' |
		rg --invert-match '(TODO|FIXME):'; then
		status=1
	fi
done
exit "$status"
