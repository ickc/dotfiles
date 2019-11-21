SHELL = /usr/bin/env bash

all:
	./make.sh

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
	[[ -n "$$NERSC_HOST" ]] && EXT='.ext' || EXT=; echo $$EXT; rm -f "$$HOME/.bash_profile$$EXT" "$$HOME/.bashrc$$EXT" "$$HOME/.zshenv$$EXT" "$$HOME/.zprofile$$EXT" "$$HOME/.zshrc$$EXT" "$$HOME/.zlogin$$EXT" "$$HOME/.zlogout" "$$HOME/.zpreztorc" "$$HOME/.p10k.zsh"
