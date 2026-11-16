.DEFAULT_GOAL = help

SHELL = /usr/bin/env bash

# location of the envoy checkout to vendor env.sh/env.fish from
ENVOY_DIR ?= $(HOME)/.local/share/envoy

# Shell sources, linted and formatted as bash: the bash/zsh startup files (which
# have no extension) and everything named *.sh, *.bash or *.zsh. Two files
# vendored from upstream stay exactly as shipped: envoy's env.sh and joshuto's
# preview script.
FIND_SH = find . -path ./.git -prune -o -type f \
	\( \
		-name dot_bash_profile -o \
		-name dot_bashrc -o \
		-name dot_zshenv -o \
		-name dot_zshrc -o \
		-name '*.bash' -o \
		-name '*.sh' -o \
		-name '*.zsh' \
	\) \
	\! -name executable_preview_file.sh \
	\! -path './dot_config/envoy/*'
# fish sources, again leaving out the copy vendored from envoy
FIND_FISH = find . -path ./.git -prune -o -type f -name '*.fish' \! -path './dot_config/envoy/*'
SHFMT = shfmt --simplify --indent 4 --case-indent --space-redirects

.PHONY: format check test todo vendor-envoy help

# The shell half is envoy's `pixi run format-sh`: shellcheck's quote-aware
# autofixes for SC2250 (braced variables) and SC2292 (double brackets) applied
# as a patch, then shfmt. A single -exec runs all three per batch, which keeps
# them in order.
format:  ## format shell sources (shellcheck autofix, shfmt) and fish sources (fish_indent)
	$(FIND_SH) -exec bash -c 'shellcheck --norc --shell=bash --enable=require-variable-braces,require-double-brackets --include=SC2250,SC2292 --format=diff "$$@" | sed -E "s#^(---|[+]{3}) ([ab])/[.]/#\1 \2/#" | git apply --allow-empty && $(SHFMT) --write "$$@"' bash {} +
	$(FIND_FISH) -exec fish_indent --write {} +

check:  ## lint (shellcheck), verify formatting (shfmt, fish_indent), syntax-check in zsh and fish
	$(FIND_SH) -exec shellcheck --norc --enable=all --shell=bash --severity=style --external-sources {} +
	$(FIND_SH) -exec $(SHFMT) --diff {} +
	$(FIND_FISH) -exec fish_indent --check {} +
	$(FIND_FISH) -print0 | xargs -0 -n 1 fish --no-execute
	for f in dot_zshenv dot_zshrc dot_config/sh/*.sh dot_config/zsh/*.zsh; do zsh -n "$$f" || exit 1; done

test:  ## apply into a throwaway destination and assert on the result (the real home is never touched)
	.github/scripts/test_apply.sh

vendor-envoy:  ## copy envoy's env.sh/env.fish into dot_config/envoy as an offline fallback
	mkdir -p dot_config/envoy
	cp $(ENVOY_DIR)/env.sh dot_config/envoy/env.sh
	cp $(ENVOY_DIR)/env.fish dot_config/envoy/env.fish

todo:  ## find TODOs in shell sources
	$(FIND_SH) -exec grep --color=auto -iHnE '(TODO|FIXME)' {} +

# by default comment out all lines in amethyst.yml due to
# https://github.com/ianyh/Amethyst/issues/1419
dot_config/amethyst/amethyst.yml:
	mkdir -p $(@D)
	curl -fsSL https://github.com/ianyh/Amethyst/raw/v0.24.3/.amethyst.sample.yml -o $@
dot_config/joshuto/:
	rm -rf $@
	mkdir -p $@
	joshuto_version_output="$$(joshuto --version | head -n 1)"; \
	version_string="$${joshuto_version_output#*-}"; \
	wget "https://github.com/kamiyaa/joshuto/archive/refs/tags/v$${version_string}.tar.gz" -O - | tar -xz --strip-components=2 -C $@ "joshuto-$${version_string}/config"
	# chezmoi sets the exec bit joshuto needs only when the source name says so
	mv $@preview_file.sh $@executable_preview_file.sh

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,cols[n],":.*##");l=length(cols[n][1]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,cols[i][1]":",cols[i][2]}' $(MAKEFILE_LIST)
