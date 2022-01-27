SHELL = /usr/bin/env bash

# option: slow, fast
MPV=fast

all: shell-install powerlevel10k-install git-install conda-install streamlink-install mpv-install

install:
	@echo "Don't allow these to change your dotfiles automatically. We'll take care of that later."
	mkdir -p $$HOME/git/fork
	cd $$HOME/git/fork; git clone git@github.com:ickc/sman.git || git clone https://github.com/ickc/sman.git
	ln -s git/fork/sman $$HOME/.sman
	mkdir -p $$HOME/.local/bin
	bash -c "$$(curl https://raw.githubusercontent.com/ickc/sman/master/install.sh)"

	mkdir -p $$HOME/git/source
	cd $$HOME/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git

	git clone --recursive https://github.com/sorin-ionescu/prezto.git "$${ZDOTDIR:-$$HOME}/.zprezto"
uninstall:
	# from install
	rm -rf $$HOME/git/fork/sman $$HOME/git/source/sman-snippets $$HOME/.zprezto $$HOME/.sman
	# from make.sh
	rm -f "$$HOME/.bash_profile" "$$HOME/.bashrc" "$$HOME/.zshenv" "$$HOME/.zprofile" "$$HOME/.zshrc" "$$HOME/.zlogin" "$$HOME/.zlogout" "$$HOME/.zpreztorc" "$$HOME/.p10k.zsh"

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

zprezto-install:
	cd zprezto; ./install.sh

streamlink-install:
	cd streamlink; ./install.sh

mpv-install:
	cd mpv; ./install.sh $(MPV)
