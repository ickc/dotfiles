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
aerospace: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
alacritty: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
conda: ; cd conda; ./install.sh
git: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
kitty: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
mpv: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@; ln -sf input-$(MPV).conf mpv/input.conf
neofetch: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
powerlevel10k: ; ln -sf $(PWD)/powerlevel10k/.p10k.zsh ~
shell: ; cd bin; ./install.sh
streamlink: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@  # https://streamlink.github.io/cli/config.html
tmux: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
wezterm: ; ln -sf $(PWD)/$@ $(XDG_CONFIG_HOME)/$@
zim: ; ln -sf $(PWD)/$@/.zimrc ~
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

# update dotfiles from upstream ########################################

.PHONY: update
update: \
	aerospace-update \
	mpv-update

.PHONY: \
	aerospace-update \
	mpv-update
aerospace-update: aerospace/aerospace.toml
aerospace/aerospace.toml: /Applications/AeroSpace.app/Contents/Resources/default-config.toml
	mkdir -p $(@D)
	cp -f $< $@
mpv-update: mpv/shaders/
mpv/shaders/:
	cd mpv; wget https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip
	unzip mpv/Anime4K_v4.0.zip -d $@
	rm mpv/Anime4K_v4.0.zip

# installing softwares #################################################

.PHONY: \
	basher-install \
	sman-install \
	zim-install \
	basher-uninstall \
	sman-uninstall \
	zim-uninstall
basher-install:
	git clone https://github.com/basherpm/basher.git ~/.basher
	~/.basher/bin/basher install ickc/dautil-sh
basher-uninstall:
	rm -rf ~/.basher
sman-install:
	curl -L https://github.com/ickc/sman/raw/master/install.sh | bash
	mkdir -p ~/git/source
	cd ~/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git
sman-uninstall:
	rm -rf \
		~/.local/bin/sman \
		~/.sman \
		~/git/source/sman-snippets
zim-install:
	curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
zim-uninstall:
	rm -rf ~/.zim

.PHONY: install uninstall
install: zim-install sman-install basher-install
software-uninstall: zim-uninstall sman-uninstall basher-uninstall

# helpers ##############################################################

.PHONY: all-uninstall
uninstall: remove software-uninstall

.PHONY: todo
todo:
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

print-%:
	$(info $* = $($*))
