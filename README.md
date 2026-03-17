# dotfiles

my public dotfiles

Put non-public env var into `dot_config/zsh/.env`.

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
. dot_config/zsh/dot_zshenv
. dot_config/zsh/dot_zshrc
chezmoi apply --source .
. dot_config/zsh/dot_zshenv
. dot_config/zsh/dot_zshrc
```
