outside_string='(?:[^"\x27\n]|"(?:[^"\\\n]|\\.)*"|\x27[^\x27\n]*\x27)*'
status=0
for file in "$@"; do
	case "$file" in
	*.nix) pattern="^\\s*(#|/\\*)|^$outside_string\\s(#|/\\*)" ;;
	*.sh | *.bash | *.yml | *.yaml) pattern="^\\s*#|^$outside_string\\s#" ;;
	*) continue ;;
	esac
	rg_status=0
	matches=$(rg --line-number --with-filename "$pattern" "$file") || rg_status=$?
	if ((rg_status > 1)); then
		status=1
	elif ((rg_status == 0)) && rg --invert-match '^[^:]+:1:#!' <<<"$matches" |
		rg --invert-match '^[^:]+:[0-9]+:\s*#\s*<?https?://\S+>?\s*$' |
		rg --invert-match '(TODO|FIXME):'; then
		status=1
	fi
done
exit "$status"
