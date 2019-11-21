all:
	./make.sh

install:
	@echo "Don't allow these to change your dotfiles automatically. We'll take care of that later."
	command -v sman || bash -c "$(curl https://raw.githubusercontent.com/ickc/sman/master/install.sh)"
	[[ -n "$ZPREZTODIR" ]] || git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
