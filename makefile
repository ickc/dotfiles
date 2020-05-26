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
	rm -f "$$HOME/.bash_profile" "$$HOME/.bashrc" "$$HOME/.zshenv" "$$HOME/.zprofile" "$$HOME/.zshrc" "$$HOME/.zlogin" "$$HOME/.zlogout" "$$HOME/.zpreztorc" "$$HOME/.p10k.zsh"
