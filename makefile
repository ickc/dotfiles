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
	powerlevel10k \
	shell
.PHONY: \
	config \
	hyper \
	mpv \
	powerlevel10k \
	shell
config:
	if [[ -d $(XDG_CONFIG_HOME) ]]; then \
		find $(XDG_CONFIG_HOME) -maxdepth 1 -type l -delete; \
		find $(XDG_CONFIG_HOME) -mindepth 1 -maxdepth 1 -exec mv {} config \;; \
		rm -rf $(XDG_CONFIG_HOME); \
	fi
	ln -s $(PWD)/config $(XDG_CONFIG_HOME)
hyper: ; ln -sf $(PWD)/home/.hyper.js ~
mpv: ; ln -sf input-$(MPV).conf config/mpv/input.conf || true
powerlevel10k: ; ln -sf $(PWD)/home/.p10k.zsh ~
shell: ; ln -sf $(PWD)/config/zsh/.zshenv ~; ln -sf $(PWD)/home/.bash_profile ~; ln -sf $(PWD)/home/.bashrc ~; ln -sf $(PWD)/home/.cshrc ~

.PHONY: remove
remove: \
	config-remove \
	hyper-remove \
	mpv-remove \
	powerlevel10k-remove \
	shell-remove
.PHONY: \
	config-remove \
	hyper-remove \
	mpv-remove \
	powerlevel10k-remove \
	shell-remove
config-remove: ; rm -f $(XDG_CONFIG_HOME) || true
hyper-remove: ; rm -f ~/.hyper.js
mpv-remove: ; rm -rf config/mpv/shaders config/mpv/input.conf
powerlevel10k-remove: ; rm -f ~/.p10k.zsh
shell-remove: ; rm -rf ~/.bash_profile ~/.bashrc ~/.zlogin ~/.zlogout ~/.zprofile ~/.zshenv ~/.zshrc

# update dotfiles from upstream ########################################

.PHONY: update
update: \
	amethyst-update \
	joshuto-update \
	mpv-update
.PHONY: \
	amethyst-update \
	joshuto-update \
	mpv-update

amethyst-update: amethyst/amethyst.yml
joshuto-update: config/joshuto/
mpv-update: config/mpv/shaders/

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
	zim-install
.PHONY: \
	basher-install \
	sman-install \
	zim-install
basher-install:
	git clone https://github.com/basherpm/basher.git ~/.basher
	~/.basher/bin/basher install ickc/dautil-sh
sman-install:
	curl -L https://github.com/ickc/sman/raw/master/install.sh | bash
	mkdir -p ~/git/source
	cd ~/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git
zim-install:
	curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh

.PHONY: uninstall-software
uninstall-software: \
	basher-uninstall \
	sman-uninstall \
	zim-uninstall
.PHONY: \
	basher-uninstall \
	sman-uninstall \
	zim-uninstall
basher-uninstall:
	rm -rf ~/.basher
sman-uninstall:
	rm -rf \
		~/.local/bin/sman \
		~/.sman \
		~/git/source/sman-snippets
zim-uninstall:
	rm -rf ~/.zim

# helpers ##############################################################

.PHONY: uninstall
uninstall: remove uninstall-software

.PHONY: format check
format:
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
check:
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
todo:
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

# TODO: delete this after migration of ZDOTDIR
migrate:
	if [[ -n "$$HISTFILE" ]]; then \
		rm -f ~/.zcompdump*; \
		mkdir -p "$$(dirname "$$HISTFILE")"; \
		[[ -f ~/.zsh_history ]] && mv -f ~/.zsh_history "$$HISTFILE"; \
		[[ -f ~/.zhistory ]] && mv -f ~/.zhistory "$$HISTFILE"; \
	fi

print-%:
	$(info $* = $($*))
