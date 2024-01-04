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
	cd ~/git/source;  -c core.sshCommand="ssh -o StrictHostKeyChecking=no" clone git@github.com:ickc/sman-snippets.git ||  -c core.sshCommand="ssh -o StrictHostKeyChecking=no" clone https://github.com/ickc/sman-snippets.git
install-basher:
	 -c core.sshCommand="ssh -o StrictHostKeyChecking=no" clone https://github.com/basherpm/basher.git ~/.basher
	~/.basher/bin/basher install ickc/dautil-sh

uninstall:
	rm -rf \
		~/.bash_profile \
		~/.basher \
		~/.bashrc \
		~/.local/bin/sman \
		~/.p10k.zsh \
		~/.sman \
		~/.zim \
		~/.zimrc \
		~/.zlogin \
		~/.zlogout \
		~/.zprofile \
		~/.zshenv \
		~/.zshrc \
		~/git/source/sman-snippets
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

print-%:
	$(info $* = $($*))
