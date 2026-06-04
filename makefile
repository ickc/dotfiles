.DEFAULT_GOAL = help

SHELL = /usr/bin/env bash

.PHONY: format check todo help

format:  ## format all shell scripts
	find . -type f \
		\( \
			-name .bash_profile -o \
			-name .bashrc -o \
			-name .cshrc -o \
			-name .zimrc -o \
			-name .zshenv -o \
			-name .zshrc -o \
			-name '*.sh' \
		\) \
		\! -name executable_preview_file.sh \
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
			-name .bash_profile -o \
			-name .bashrc -o \
			-name .cshrc -o \
			-name .zimrc -o \
			-name .zshenv -o \
			-name .zshrc -o \
			-name '*.sh' \
		\) \
		\! -name executable_preview_file.sh \
		-exec shellcheck \
			--norc \
			--enable=all \
			--shell=bash \
			--severity=style \
			{} +

todo:  ## find TODOs in shell scripts
	find . -type f \
		\( \
			-name .bash_profile -o \
			-name .bashrc -o \
			-name .cshrc -o \
			-name .zimrc -o \
			-name .zshenv -o \
			-name .zshrc -o \
			-name '*.sh' \
		\) \
		-exec grep --color=auto -iHnE '(TODO|FIXME)' {} +

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,cols[n],":.*##");l=length(cols[n][1]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,cols[i][1]":",cols[i][2]}' $(MAKEFILE_LIST)
