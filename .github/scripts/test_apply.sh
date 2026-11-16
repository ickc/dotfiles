#!/usr/bin/env bash
# Apply the source state into a throwaway destination and assert on the result.
# The real home is never touched: destination, config, persistent state and
# cache all live under one temp dir. Set OFFLINE=1 to skip the externals (the
# zsh plugin archives), which need the network.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
dest="${tmp}/home"

fail=0
ok() { printf 'ok    %s\n' "$1"; }
bad() {
    printf 'FAIL  %s\n' "$1"
    fail=1
}
# check DESCRIPTION COMMAND...: run the command and report whether it succeeded
check() {
    local what=$1
    shift
    if "$@" > /dev/null 2>&1; then ok "${what}"; else bad "${what}"; fi
}
# mode_is PATH MODE: true if PATH has exactly that permission mode
mode_is() { find "$1" -prune -perm "$2" | grep -q .; }

# Seed what .chezmoiremove must clear, next to a bystander it must leave alone.
mkdir -p "${dest}/scripts"
: > "${tmp}/chezmoi.toml"
: > "${dest}/scripts/update_chezmoi_externals.py"
: > "${dest}/scripts/keep-me"
: > "${dest}/.cshrc"

exclude=()
[[ ${OFFLINE:-0} == 1 ]] && exclude=(--exclude=externals)

# The ${a[@]+"${a[@]}"} form keeps an empty array from tripping `set -u` on the
# bash 3.2 that macOS ships.
chezmoi apply \
    --source "${src}" \
    --destination "${dest}" \
    --config "${tmp}/chezmoi.toml" \
    --persistent-state "${tmp}/state.boltdb" \
    --cache "${tmp}/cache" \
    --no-tty --force \
    ${exclude[@]+"${exclude[@]}"}

cd "${dest}"

# files chezmoi drops unless the source name says otherwise
check "empty wgetrc exists (WGETRC points at it)" test -f .config/wgetrc
check "empty parallel will-cite exists" test -f .config/parallel/will-cite
check "joshuto preview script is executable" test -x .config/joshuto/preview_file.sh
check "zed settings are private (0600)" mode_is .config/zed/settings.json 600

# .chezmoiremove
check "stray ~/scripts updater copy is removed" test ! -e scripts/update_chezmoi_externals.py
check "other files in ~/scripts are left alone" test -e scripts/keep-me
check "legacy ~/.cshrc is removed" test ! -e .cshrc

# repo metadata stays out of the home directory
for f in README.md LICENSE makefile .github; do
    check "${f} is not deployed" test ! -e "${f}"
done

# per-OS content
os="$(uname -s)"
if [[ ${os} == Darwin ]]; then
    check "amethyst config is deployed on macOS" test -f .config/amethyst/amethyst.yml
else
    check "amethyst config is skipped off macOS" test ! -e .config/amethyst
fi

check "git config parses" git config --file .config/git/config --list

if [[ ${OFFLINE:-0} != 1 ]]; then
    plugins=.local/share/zsh/plugins
    check "zsh-autosuggestions is fetched" test -r "${plugins}/zsh-autosuggestions/zsh-autosuggestions.zsh"
    check "zsh-syntax-highlighting is fetched" test -r "${plugins}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    check "zsh-history-substring-search is fetched" test -r "${plugins}/zsh-history-substring-search/zsh-history-substring-search.zsh"
    check "zsh-completions is fetched" test -d "${plugins}/zsh-completions/src"
fi

# The env files must stand alone: the fake home has no envoy checkout, so the
# vendored copy has to supply the prefixes. Non-interactive on purpose — the
# interactive rc would start an ssh-agent.
# smoke SHELL COMMAND: COMMAND must print __OPT_ROOT
smoke() {
    local sh=$1 cmd=$2 out
    if ! command -v "${sh}" > /dev/null 2>&1; then
        printf 'skip  %s is not installed\n' "${sh}"
        return 0
    fi
    out="$(env -i HOME="${dest}" PATH="${PATH}" "${sh}" -c "${cmd}")" || true
    if [[ ${out} == "${dest}/.local/opt/"* ]]; then
        ok "${sh} gets __OPT_ROOT from the vendored envoy env"
    else
        bad "${sh} env: expected __OPT_ROOT under ${dest}/.local/opt/, got '${out}'"
    fi
}
# shellcheck disable=SC2016  # expanded by the shell under test, not this one
{
    smoke bash '. ~/.bashrc && printf %s "${__OPT_ROOT}"'
    smoke zsh 'printf %s "${__OPT_ROOT}"'
    smoke fish 'printf %s $__OPT_ROOT'
}

if [[ ${fail} -ne 0 ]]; then
    echo "target-state checks failed" >&2
    exit 1
fi
echo "all target-state checks passed"
