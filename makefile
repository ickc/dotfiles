SHELL = /usr/bin/env bash

# option: slow, fast
MPV=fast

.PHONY: default install install-zim install-sman install-basher uninstall todo
default: all

install: install-zim install-sman install-basher
install-zim:
	curl -fsSL --create-dirs -o ~/.zim/zimfw.zsh https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
install-sman:
	curl -L https://github.com/ickc/sman/raw/master/install.sh | bash
	mkdir -p ~/git/source
	cd ~/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git
install-basher:
	git clone https://github.com/basherpm/basher.git ~/.basher
	~/.basher/bin/basher install ickc/dautil-sh

uninstall:
	# from install
	rm -rf ~/.zim ~/.sman ~/git/source/sman-snippets ~/.basher
	# from make.sh
	rm -f "~/.bash_profile" "~/.bashrc" "~/.zshenv" "~/.zprofile" "~/.zshrc" "~/.zlogin" "~/.zlogout" "~/.zimrc" "~/.p10k.zsh"
todo:
	find bin -type f -exec grep --color=auto -iHnE '(TODO|printerr|Deprecation)' {} +

# individual ###########################################################

.PHONY: all shell-install powerlevel10k-install git-install conda-install zim-install streamlink-install mpv-install tmux-install neofetch-install alacritty-install
all: shell-install powerlevel10k-install git-install conda-install zim-install streamlink-install mpv-install tmux-install neofetch-install alacritty-install
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

neofetch-install:
	cd neofetch; ./install.sh

alacritty-install:
	cd alacritty; ./install.sh
