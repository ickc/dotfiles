SHELL = /usr/bin/env bash

# option: slow, fast
MPV=fast

all: shell-install powerlevel10k-install git-install conda-install zim-install streamlink-install mpv-install tmux-install

install-zim:
	curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
install: install-zim
	@echo "Don't allow these to change your dotfiles automatically. We'll take care of that later."
	mkdir -p $$HOME/git/fork
	cd $$HOME/git/fork; git clone git@github.com:ickc/sman.git || git clone https://github.com/ickc/sman.git
	ln -s git/fork/sman $$HOME/.sman
	mkdir -p $$HOME/.local/bin
	bash -c "$$(curl https://raw.githubusercontent.com/ickc/sman/master/install.sh)"

	mkdir -p $$HOME/git/source
	cd $$HOME/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git
uninstall:
	# from install
	rm -rf $$HOME/git/fork/sman $$HOME/git/source/sman-snippets $$HOME/.zim $$HOME/.sman
	# from make.sh
	rm -f "$$HOME/.bash_profile" "$$HOME/.bashrc" "$$HOME/.zshenv" "$$HOME/.zprofile" "$$HOME/.zshrc" "$$HOME/.zlogin" "$$HOME/.zlogout" "$$HOME/.zimrc" "$$HOME/.p10k.zsh"
uninstall-zprezto:
	rm -rf "$$HOME/.zprezto"
	rm -f "$$HOME/.zpreztorc"
todo:
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

# individual ###########################################################

shell-install:
	cd bin; ./install.sh

powerlevel10k-install:
	cd powerlevel10k; ./install.sh

git-install:
	cd git; ./install.sh

conda-install:
	cd conda; ./install.sh

zim-install:
	cd zim; ./install.sh

streamlink-install:
	cd streamlink; ./install.sh

mpv-install:
	cd mpv; ./install.sh $(MPV)

tmux-install:
	cd tmux; ./install.sh
