SHELL = /usr/bin/env bash
GIT_SSH_COMMAND = ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
export GIT_SSH_COMMAND

# option: slow, fast
MPV=fast

# installing dotfiles ##################################################

.PHONY: all
all: \
	aerospace-install \
	alacritty-install \
	conda-install \
	git-install \
	kitty-install \
	mpv-install \
	neofetch-install \
	powerlevel10k-install \
	shell-install \
	streamlink-install \
	tmux-install \
	wezterm-install \
	zim-install

.PHONY: \
	aerospace-install \
	alacritty-install \
	conda-install \
	git-install \
	kitty-install \
	mpv-install \
	neofetch-install \
	powerlevel10k-install \
	shell-install \
	streamlink-install \
	tmux-install \
	wezterm-install \
	zim-install
aerospace-install: ; cd aerospace; ../src/ln_pwd_XDG_CONFIG_HOME.sh
alacritty-install: ; cd alacritty; ./install.sh
conda-install: ; cd conda; ./install.sh
git-install: ; cd git; ./install.sh
kitty-install: ; cd kitty; ./install.sh
mpv-install: ; cd mpv; ./install.sh $(MPV)
neofetch-install: ; cd neofetch; ./install.sh
powerlevel10k-install: ; cd powerlevel10k; ./install.sh
shell-install: ; cd bin; ./install.sh
streamlink-install: ; cd streamlink; ./install.sh
tmux-install: ; cd tmux; ./install.sh
wezterm-install: ; cd wezterm; ./install.sh
zim-install: ; cd zim; ./install.sh

.PHONY: uninstall-dotfiles
uninstall-dotfiles:
	rm -rf \
		~/.bash_profile \
		~/.bashrc \
		~/.p10k.zsh \
		~/.zimrc \
		~/.zlogin \
		~/.zlogout \
		~/.zprofile \
		~/.zshenv \
		~/.zshrc

# update dotfiles from upstream ########################################

.PHONY: update
update: \
	aerospace-update

.PHONY: \
	aerospace-update
aerospace-update: aerospace/aerospace.toml
aerospace/aerospace.toml: /Applications/AeroSpace.app/Contents/Resources/default-config.toml
	mkdir -p $(@D)
	cp -f $< $@

# installing softwares #################################################

.PHONY: \
	install-basher \
	install-sman \
	install-zim \
	uninstall-basher \
	uninstall-sman \
	uninstall-zim
install-basher:
	git clone https://github.com/basherpm/basher.git ~/.basher
	~/.basher/bin/basher install ickc/dautil-sh
uninstall-basher:
	rm -rf ~/.basher
install-sman:
	curl -L https://github.com/ickc/sman/raw/master/install.sh | bash
	mkdir -p ~/git/source
	cd ~/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git
uninstall-sman:
	rm -rf \
		~/.local/bin/sman \
		~/.sman \
		~/git/source/sman-snippets
install-zim:
	curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
uninstall-zim:
	rm -rf ~/.zim

.PHONY: install uninstall
install: install-zim install-sman install-basher
uninstall: uninstall-zim uninstall-sman uninstall-basher

# helpers ##############################################################

.PHONY: uninstall-all
uninstall-all: uninstall uninstall-dotfiles

.PHONY: todo
todo:
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

print-%:
	$(info $* = $($*))
