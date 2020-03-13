#!/bin/sh

################################################################################
# install
#
# This script symlinks dotfiles into place in the home and config directories
################################################################################

dotfiles_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\\n[DOTFILES] $fmt\\n" "$@"
}

set -e # Terminate script if anything exits with a non-zero value

DOTFILES_DIR=$HOME/dotfiles

if [ -z "$XDG_CONFIG_HOME" ]; then
  if [ ! -d "$HOME/.config" ]; then
    mkdir "$HOME/.config"
  fi
  CONFIG_DIR=$HOME/.config
else
  CONFIG_DIR=$XDG_CONFIG_HOME
fi

home_files=(
"asdfrc"
"default-gems"
"default-npm-packages"
"gemrc"
"gitconfig"
"gitignore_global"
"gitmessage"
"gitsh_completions"
"hushlogin"
"npmrc"
"pryrc"
"rubocop.yml"
"svgo.yml"
"tmux.conf"
"tool-versions"
"zshrc"
)

config_dirs=(
"nvim"
"omf"
"ranger"
)

dotfiles_echo "Installing dotfiles..."

for item in "${home_files[@]}"; do
  if [ -e "$HOME"/."$item" ]; then
    dotfiles_echo ".${item} exists."
    if [ -L "$HOME"/."$item" ]; then
      dotfiles_echo "Symbolic link detected. Removing..."
      rm -v "$HOME"/."$item"
    else
      dotfiles_echo "Backing up..."
      mv -v "$HOME"/."$item" "$HOME"/."${item}_backup"
    fi
  fi
  dotfiles_echo "-> Linking $DOTFILES_DIR/$item to $HOME/.$item..."
  ln -nfs "$DOTFILES_DIR"/"$item" "$HOME"/."$item"
done

if [ -e "$HOME"/Brewfile ]; then
  dotfiles_echo "Brewfile exists."
  if [ -L "$HOME"/Brewfile ]; then
    dotfiles_echo "Symbolic link detected. Removing..."
    rm -v "$HOME"/Brewfile
  else
    dotfiles_echo "Backing up..."
    mv -v "$HOME"/Brewfile "$HOME"/Brewfile_backup
  fi
fi
dotfiles_echo "-> Linking $DOTFILES_DIR/Brewfile to $HOME/Brewfile..."
ln -nfs "$DOTFILES_DIR"/Brewfile "$HOME"/Brewfile

for item in "${config_dirs[@]}"; do
  if [ -d "$CONFIG_DIR"/"$item" ]; then
    dotfiles_echo "Directory ${item} exists."
    if [ -L "$CONFIG_DIR"/"$item" ]; then
      dotfiles_echo "Symbolic link detected. Removing..."
      rm -v "$CONFIG_DIR"/"$item"
    else
      dotfiles_echo "Backing up..."
      mv -v "$CONFIG_DIR"/"$item" "$CONFIG_DIR"/"${item}_backup"
    fi
  fi
  dotfiles_echo "-> Linking $DOTFILES_DIR/$item to $CONFIG_DIR/$item..."
  ln -nfs "$DOTFILES_DIR"/"$item" "$CONFIG_DIR"/"$item"
done

if [ -e "$CONFIG_DIR"/starship.toml ]; then
  dotfiles_echo "starship.toml exists."
  if [ -L "$CONFIG_DIR"/starship.toml ]; then
    dotfiles_echo "Symbolic link detected. Removing..."
    rm -v "$CONFIG_DIR"/starship.toml
  else
    dotfiles_echo "Backing up..."
    mv -v "$CONFIG_DIR"/starship.toml "$CONFIG_DIR"/starship_backup.toml
  fi
fi
dotfiles_echo "-> Linking $DOTFILES_DIR/starship.toml to $CONFIG_DIR/starship.toml..."
ln -nfs "$DOTFILES_DIR"/starship.toml "$CONFIG_DIR"/starship.toml

dotfiles_echo "-> Installing vim-plug plugins..."
nvim --headless +PlugInstall +qall

dotfiles_echo "Dotfiles installation complete!"

dotfiles_echo "Post-install recommendations:"
dotfiles_echo "- Complete Brew Bundle installation with 'brew bundle install'"
dotfiles_echo "- After launching Neovim, run :checkhealth and resolve any errors/warnings."
