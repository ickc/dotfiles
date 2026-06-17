.DEFAULT_GOAL = help

SHELL = /usr/bin/env bash

# location of the envoy checkout to vendor env.sh/env.fish from
ENVOY_DIR ?= $(HOME)/.local/share/envoy

.PHONY: format check todo vendor-envoy help

format:  ## format all shell scripts
	find . -type f \
		\( \
			-name dot_bash_profile -o \
			-name dot_bashrc -o \
			-name dot_cshrc -o \
			-name dot_zshenv -o \
			-name dot_zshrc -o \
			-name '*.bash' -o \
			-name '*.sh' \
		\) \
		\! -name executable_preview_file.sh \
		\! -path './dot_config/envoy/*' \
		-exec sed -i -E \
			-e 's/\$$([a-zA-Z_][a-zA-Z0-9_]*)/$${\1}/g' \
			-e 's/([^[])\[ ([^]]+) \]/\1[[ \2 ]]/g' \
			{} + \
		-exec shfmt \
			--write \
			--simplify \
			--indent 4 \
			--case-indent \
			--space-redirects \
			{} +

check:  ## check all shell scripts
	find . -type f \
		\( \
			-name dot_bash_profile -o \
			-name dot_bashrc -o \
			-name dot_cshrc -o \
			-name dot_zshenv -o \
			-name dot_zshrc -o \
			-name '*.bash' -o \
			-name '*.sh' \
		\) \
		\! -name executable_preview_file.sh \
		\! -path './dot_config/envoy/*' \
		-exec shellcheck \
			--norc \
			--enable=all \
			--shell=bash \
			--severity=style \
			{} +

vendor-envoy:  ## copy envoy's env.sh/env.fish into dot_config/envoy as an offline fallback
	mkdir -p dot_config/envoy
	cp $(ENVOY_DIR)/env.sh dot_config/envoy/env.sh
	cp $(ENVOY_DIR)/env.fish dot_config/envoy/env.fish

todo:  ## find TODOs in shell scripts
	find . -type f \
		\( \
			-name dot_bash_profile -o \
			-name dot_bashrc -o \
			-name dot_cshrc -o \
			-name dot_zshenv -o \
			-name dot_zshrc -o \
			-name '*.bash' -o \
			-name '*.sh' \
		\) \
		-exec grep --color=auto -iHnE '(TODO|FIXME)' {} +

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

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,cols[n],":.*##");l=length(cols[n][1]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,cols[i][1]":",cols[i][2]}' $(MAKEFILE_LIST)
