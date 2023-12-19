# dotfiles

my public dotfiles

Put non-public env var into `bin/.env`.

# Dependencies

- conda & mamba
- zim
- sman
- basher

# Install

```bash
mkdir -p ~/git/source; cd ~/git/source
git clone git@github.com:ickc/dotfiles.git ||
git clone https://github.com/ickc/dotfiles.git
cd dotfiles
make uninstall && make install && make
```
