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
	aerospace \
	alacritty \
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
	aerospace \
	alacritty \
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
aerospace: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
alacritty: ; rm -rf $(XDG_CONFIG_HOME)/$@; ln -s $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
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
	aerospace-remove \
	alacritty-remove \
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
	aerospace-remove \
	alacritty-remove \
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
aerospace-remove: ; rm -rf $(XDG_CONFIG_HOME)/aerospace
alacritty-remove: ; rm -rf $(XDG_CONFIG_HOME)/alacritty
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
	aerospace-update \
	mpv-update
.PHONY: \
	aerospace-update \
	mpv-update
aerospace-update: aerospace/aerospace.toml
mpv-update: mpv/shaders/

aerospace/aerospace.toml: /Applications/AeroSpace.app/Contents/Resources/default-config.toml
	mkdir -p $(@D)
	cp -f $< $@
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
