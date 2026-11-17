cd "$(mktemp -d)" || exit

expect_exit() {
	local expected=$1 scenario=$2
	shift 2
	local actual=0
	"$@" >/dev/null 2>&1 || actual=$?
	if [[ $actual -ne $expected ]]; then
		echo "$scenario: exit $actual, expected $expected" >&2
		exit 1
	fi
}

printf 'x = 1;\n' >clean.nix
printf '# note\nx = 1;\n' >commented.nix
printf '\xc3\xa9\n' >accent.txt

expect_exit 0 "no-comment clean" no-comment clean.nix
expect_exit 1 "no-comment comment" no-comment commented.nix
expect_exit 1 "no-comment missing file" no-comment missing.nix
expect_exit 0 "ascii-only clean" ascii-only clean.nix
expect_exit 1 "ascii-only non-ascii" ascii-only accent.txt
expect_exit 1 "ascii-only missing file" ascii-only missing.txt
