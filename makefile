.DEFAULT_GOAL = help

SHELL = /usr/bin/env bash
GIT_SSH_COMMAND = ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
export GIT_SSH_COMMAND
XDG_CONFIG_HOME ?= $(HOME)/.config
export XDG_CONFIG_HOME

# option: slow, fast
MPV=fast

# installing dotfiles ##################################################

.PHONY: all
all: \
	config \
	hyper \
	mpv \
	shell \
	taskfile  ## install all dotfiles
.PHONY: \
	config \
	hyper \
	mpv \
	shell \
	taskfile
config:  ## setup config (moving existing config then symlink)
	if [[ -d $(XDG_CONFIG_HOME) ]]; then \
		find $(XDG_CONFIG_HOME) -maxdepth 1 -type l -delete; \
		find $(XDG_CONFIG_HOME) -mindepth 1 -maxdepth 1 -exec mv {} config \;; \
		rm -rf $(XDG_CONFIG_HOME); \
	fi
	ln -s $(PWD)/config $(XDG_CONFIG_HOME)
hyper: ; ln -sf $(PWD)/home/.hyper.js ~  ## setup hyper dotfile
mpv: ; ln -sf input-$(MPV).conf config/mpv/input.conf || true  ## setup mpv dotfile
shell: ; ln -sf $(PWD)/config/zsh/.zshenv ~; ln -sf $(PWD)/home/.bash_profile ~; ln -sf $(PWD)/home/.bashrc ~; ln -sf $(PWD)/home/.cshrc ~  ## setup shell dotfiles
taskfile: ; ln -sf $(PWD)/home/Taskfile.yml ~  ## setup taskfile at HOME

# TODO: delete powerlevel10k-remove
.PHONY: remove
remove: \
	config-remove \
	hyper-remove \
	mpv-remove \
	powerlevel10k-remove \
	shell-remove \
	taskfile-remove  ## remove all dotfiles
.PHONY: \
	config-remove \
	hyper-remove \
	mpv-remove \
	powerlevel10k-remove \
	shell-remove \
	taskfile-remove
config-remove: ; rm -f $(XDG_CONFIG_HOME) || true  ## remove config symlink
hyper-remove: ; rm -f ~/.hyper.js  ## remove hyper dotfile
mpv-remove: ; rm -rf config/mpv/shaders config/mpv/input.conf  ## remove mpv dotfile
powerlevel10k-remove: ; rm -f ~/.p10k.zsh  ## remove powerlovel10k dotfile
shell-remove: ; rm -rf ~/.bash_profile ~/.bashrc ~/.zlogin ~/.zlogout ~/.zprofile ~/.zshenv ~/.zshrc  ## remove shell dotfiles
taskfile-remove: ; rm -f ~/Taskfile.yml  ## remove taskfile symlink at HOME

# update dotfiles from upstream ########################################

.PHONY: update
update: \
	amethyst-update \
	joshuto-update \
	mpv-update  ## update dotfiles from upstream
.PHONY: \
	amethyst-update \
	joshuto-update \
	mpv-update

amethyst-update: amethyst/amethyst.yml  ## update amethyst config
joshuto-update: config/joshuto/  ## update joshuto config
mpv-update: config/mpv/shaders/  ## update mpv config

# by default comment out all lines in amethyst.yml due to
# https://github.com/ianyh/Amethyst/issues/1419
amethyst/amethyst.yml:
	mkdir -p $(@D)
	wget https://github.com/ianyh/Amethyst/raw/development/.amethyst.sample.yml -O $@
	sed -i '/^\s*#/!{/^$$/!s/^/# /}' $@
config/joshuto/:
	rm -rf $@
	mkdir -p $@
	joshuto_version_output="$$(joshuto --version | head -n 1)"; \
	version_string="$${joshuto_version_output#*-}"; \
	wget "https://github.com/kamiyaa/joshuto/archive/refs/tags/v$${version_string}.tar.gz" -O - | tar -xz --strip-components=2 -C $@ "joshuto-$${version_string}/config"
config/mpv/shaders/:
	cd config/mpv; wget https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip
	unzip config/mpv/Anime4K_v4.0.zip -d $@
	rm config/mpv/Anime4K_v4.0.zip

# installing softwares #################################################

.PHONY: install
install: \
	basher-install \
	sman-install \
	zim-install  ## install all softwares
.PHONY: \
	basher-install \
	sman-install \
	zim-install
basher-install:  ## install basher
	git clone https://github.com/basherpm/basher.git ~/.basher
	~/.basher/bin/basher install ickc/dautil-sh
sman-install:  ## install sman
	curl -L https://github.com/ickc/sman/raw/master/install.sh | bash
	mkdir -p ~/git/source
	cd ~/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git
zim-install:  ## install zim
	curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh

.PHONY: uninstall-software
uninstall-software: \
	basher-uninstall \
	sman-uninstall \
	zim-uninstall  ## uninstall all softwares
.PHONY: \
	basher-uninstall \
	sman-uninstall \
	zim-uninstall
basher-uninstall:  ## uninstall basher
	rm -rf ~/.basher
sman-uninstall:  ## uninstall sman
	rm -rf \
		~/.local/bin/sman \
		~/.sman \
		~/git/source/sman-snippets
zim-uninstall:  ## uninstall zim
	rm -rf ~/.zim

# helpers ##############################################################

.PHONY: uninstall
uninstall: remove uninstall-software  ## remove all dotfiles and uninstall all softwares

.PHONY: format check
format:  ## format all shell scripts
	find . -type f \
		\( \
			-name .bash_profile -o \
			-name .bashrc -o \
			-name .env -o \
			-name .zimrc -o \
			-name .zshenv -o \
			-name .zshrc -o \
			-name '*.sh' \
		\) \
		\! -name preview_file.sh \
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
			-name .env -o \
			-name .zimrc -o \
			-name .zshenv -o \
			-name .zshrc -o \
			-name '*.sh' \
		\) \
		\! -name preview_file.sh \
		-exec shellcheck \
			--norc \
			--enable=all \
			--shell=bash \
			--severity=style \
			{} +

.PHONY: todo
todo:  ## find TODOs in all shell scripts
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

# TODO: delete this after migration of ZDOTDIR
migrate:  ## migrate zsh history to ZDOTDIR
	if [[ -n "$$HISTFILE" ]]; then \
		rm -f ~/.zcompdump*; \
		mkdir -p "$$(dirname "$$HISTFILE")"; \
		[[ -f ~/.zsh_history ]] && mv -f ~/.zsh_history "$$HISTFILE"; \
		[[ -f ~/.zhistory ]] && mv -f ~/.zhistory "$$HISTFILE"; \
	fi

print-%:
	$(info $* = $($*))

help:  ## print this help message
	@awk 'BEGIN{w=0;n=0}{while(match($$0,/\\$$/)){sub(/\\$$/,"");getline nextLine;$$0=$$0 nextLine}if(/^[[:alnum:]_-]+:.*##.*$$/){n++;split($$0,cols[n],":.*##");l=length(cols[n][1]);if(w<l)w=l}}END{for(i=1;i<=n;i++)printf"\033[1m\033[93m%-*s\033[0m%s\n",w+1,cols[i][1]":",cols[i][2]}' $(MAKEFILE_LIST)
