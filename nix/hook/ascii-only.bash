status=0
for file in "$@"; do
	case "$file" in
	*.md) rg_option_list=(--encoding utf-8 '[[^\x00-\x7F]--[\p{Latin}&&\p{L}]]') ;;
	*) rg_option_list=(--no-unicode '[\x80-\xFF]') ;;
	esac
	if rg --line-number --with-filename "${rg_option_list[@]}" "$file"; then
		status=1
	fi
done
exit "$status"
