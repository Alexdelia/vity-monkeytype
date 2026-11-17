status=0
for file in "$@"; do
	case "$file" in
	*.md) rg_option_list=(--encoding utf-8 '[[^\x00-\x7F]--[\p{Latin}&&\p{L}]]') ;;
	*) rg_option_list=(--no-unicode '[\x80-\xFF]') ;;
	esac
	rg_status=0
	rg --line-number --with-filename "${rg_option_list[@]}" "$file" || rg_status=$?
	if ((rg_status != 1)); then
		status=1
	fi
done
exit "$status"
