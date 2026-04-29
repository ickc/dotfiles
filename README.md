# dotfiles

my public dotfiles

Put non-public env var into `home/.env`.

# Dependencies

- conda & mamba
- zim
- sman

# Install

```bash
mkdir -p ~/git/source
cd ~/git/source
git clone git@github.com:ickc/dotfiles.git ||
git clone https://github.com/ickc/dotfiles.git
cd dotfiles
. home/.zshenv
. home/.zshrc
make uninstall && make install && make
. home/.zshenv
. home/.zshrc
```
