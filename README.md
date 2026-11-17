# vity-monkeytype

[vity](https://github.com/Alexdelia/vity-base24) theme for [monkeytype](https://monkeytype.com).

## install

[open in monkeytype](https://monkeytype.com?customTheme=eyJjIjpbIiMxMTExMTEiLCIjYTAyMGYwIiwiI2ZmZDFmZiIsIiM4MDgwODAiLCIjMjAyMDIwIiwiI2UwZTBlMCIsIiNkMzJmMmYiLCIjOTYwNzA3IiwiI2ZmMDAwMCIsIiNkMzJmMmYiXX0%3D) to apply as custom theme, or copy:

```
https://monkeytype.com?customTheme=eyJjIjpbIiMxMTExMTEiLCIjYTAyMGYwIiwiI2ZmZDFmZiIsIiM4MDgwODAiLCIjMjAyMDIwIiwiI2UwZTBlMCIsIiNkMzJmMmYiLCIjOTYwNzA3IiwiI2ZmMDAwMCIsIiNkMzJmMmYiXX0%3D
```

or print it:

```sh
nix run github:Alexdelia/vity-monkeytype
```

## any base16 / base24 scheme

```sh
nix run github:Alexdelia/vity-monkeytype#generate -- path/to/scheme.yaml
```

without nix, `yq` ([yq-go](https://github.com/mikefarah/yq)) and `jq` on `PATH`:

```sh
./generate.sh path/to/scheme.yaml
```

base24 slot -> monkeytype color mapping: [`generate.sh`](generate.sh). base16 schemes: `colorfulError` falls back to `base08`.

## freshness

- link above generated from `vity.yaml` pinned in `flake.lock`
- `readme-url` git hook rewrites README link on every commit
- `nix flake check` fails when README link differs from generated one, run on every push by [check workflow](.github/workflows/check.yml)
- after vity change: `nix flake update vity-base24`, then commit

## development

```sh
direnv allow
```

or `nix develop`. Both install git hooks (formatting, lint, typos, README link).
