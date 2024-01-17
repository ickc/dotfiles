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
	alacritty \
	amethyst \
	conda \
	git \
	kitty \
	mpv \
	neofetch \
	powerlevel10k \
	shell \
	streamlink \
	tmux \
	wezterm \
	zim
.PHONY: \
	alacritty \
	amethyst \
	conda \
	git \
	kitty \
	mpv \
	neofetch \
	powerlevel10k \
	shell \
	streamlink \
	tmux \
	wezterm \
	zim
alacritty: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
amethyst: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
conda: ; cd conda; ./install.sh
git: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
kitty: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
mpv: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@; ln -sf input-$(MPV).conf mpv/input.conf
neofetch: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
powerlevel10k: ; ln -sf $(PWD)/powerlevel10k/.p10k.zsh ~
shell: ; cd bin; ./install.sh
streamlink: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@  # https://streamlink.github.io/cli/config.html
tmux: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
wezterm: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
zim: ; ln -sf $(PWD)/$@/.zimrc ~

.PHONY: remove
remove: \
	alacritty-remove \
	amethyst-remove \
	conda-remove \
	git-remove \
	kitty-remove \
	mpv-remove \
	neofetch-remove \
	powerlevel-remove10k \
	shell-remove \
	streamlink-remove \
	tmux-remove \
	wezterm-remove \
	zim-remove
.PHONY: \
	alacritty-remove \
	amethyst-remove \
	conda-remove \
	git-remove \
	kitty-remove \
	mpv-remove \
	neofetch-remove \
	powerlevel-remove10k \
	shell-remove \
	streamlink-remove \
	tmux-remove \
	wezterm-remove \
	zim-remove
alacritty-remove: ; rm -rf $(XDG_CONFIG_HOME)/alacritty
amethyst-remove: ; rm -rf $(XDG_CONFIG_HOME)/amethyst
conda-remove: ; cd conda; ./uninstall.sh
git-remove: ; rm -rf $(XDG_CONFIG_HOME)/git
kitty-remove: ; rm -rf $(XDG_CONFIG_HOME)/kitty
mpv-remove: ; rm -rf $(XDG_CONFIG_HOME)/mpv mpv/shaders mpv/input.conf
neofetch-remove: ; rm -rf $(XDG_CONFIG_HOME)/neofetch
powerlevel-remove10k: ; rm -rf ~/.p10k.zsh
shell-remove: ; cd bin; ./uninstall.sh
streamlink-remove: ; rm -rf $(XDG_CONFIG_HOME)/streamlink
tmux-remove: ; rm -rf $(XDG_CONFIG_HOME)/tmux
wezterm-remove: ; rm -rf $(XDG_CONFIG_HOME)/wezterm
zim-remove: ; rm -rf ~/.zimrc

# update dotfiles from upstream ########################################

.PHONY: update
update: \
	amethyst-update \
	mpv-update
.PHONY: \
	amethyst-update \
	mpv-update

amethyst-update: amethyst/amethyst.yml
mpv-update: mpv/shaders/

# by default comment out all lines in amethyst.yml due to
# https://github.com/ianyh/Amethyst/issues/1419
amethyst/amethyst.yml:
	mkdir -p $(@D)
	wget https://github.com/ianyh/Amethyst/raw/development/.amethyst.sample.yml -O $@
	sed -i '/^\s*#/!{/^$$/!s/^/# /}' $@
mpv/shaders/:
	cd mpv; wget https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip
	unzip mpv/Anime4K_v4.0.zip -d $@
	rm mpv/Anime4K_v4.0.zip

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

.PHONY: todo
todo:
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

print-%:
	$(info $* = $($*))
