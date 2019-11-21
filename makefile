all:
	./make.sh

install:
	@echo "Don't allow these to change your dotfiles automatically. We'll take care of that later."
	mkdir -p ~/git/fork
	cd ~/git/fork; git clone git@github.com:ickc/sman.git || git clone https://github.com/ickc/sman.git
	ln -s git/fork ~/.sman
	mkdir -p ~/.local/bin
	bash -c "$(curl https://raw.githubusercontent.com/ickc/sman/master/install.sh)"

	mkdir -p ~/git/source
	cd ~/git/source; git clone git@github.com:ickc/sman-snippets.git || git clone https://github.com/ickc/sman-snippets.git

	git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-~}/.zprezto"
uninstall:
	# from install
	rm -rf ~/git/fork/sman ~/git/source/sman-snippets ~/.zprezto ~/.sman
	# from make.sh
	[[ -n "$$NERSC_HOST" ]] && EXT='.ext' || EXT=; rm -f "~/.bash_profile$$EXT" "~/.bashrc$$EXT" "~/.zshenv$$EXT" "~/.zprofile$$EXT" "~/.zshrc$$EXT" "~/.zlogin$$EXT" "~/.zlogout" "~/.zpreztorc" "~/.p10k.zsh"
