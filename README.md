# dotfiles

my public dotfiles

Put non-public env var into `config/zsh/.env`.

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
. config/zsh/.zshenv
. config/zsh/.zshrc
make uninstall && make install && make
. config/zsh/.zshenv
. config/zsh/.zshrc
```
