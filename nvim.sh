#!/bin/bash

export NVIM_DIR="$HOME/.config/nvim"

# Checking if Neovim is Installed
if [ ! -x "$(command -v nvim)" ]; then
  echo "${red}Neovim not Installed${reset}"
  echo "${yellow}Installing Neovim binary..."

  echo "Which version of Neovim would you like to install?"
  echo
  read -p "Enter 's' for stable or 'n' for nightly:" VERSION

  if [[ "$VERSION" == "s" ]]; then
    printf "\nInstalling Stable version...\n"
  elif [[ "$VERSION" == "n" ]]; then
    printf "\nInstalling Nightly version...\n"
  fi

  [ -d "$HOME/neovim" ] && rm -rf "$HOME/neovim"
  mkdir "$HOME/neovim"
  cd "$HOME/neovim" || exit

  if [[ "$VERSION" == "s" ]]; then
    curl -sLO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    sudo chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract
    ./squashfs-root/AppRun --version
    sudo mv squashfs-root /
    sudo mv /squashfs-root/AppRun /usr/bin/nvim
  elif [[ "$VERSION" == "n" ]]; then
    git clone --quiet --depth 1 --branch nightly https://github.com/neovim/neovim.git
    cd neovim || exit
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
  fi
fi
echo "${green}Neovim is installed. Installing configs...${reset}"

## Back up current config
echo "Backin up current config..." && sleep 2
[ -d "$NVIM_DIR.backup" ] && rm -rf "$NVIM_DIR.backup"
[ -d $NVIM_DIR ] && mv $NVIM_DIR "$NVIM_DIR.backup"

## Optional but recommended
echo "Removing old cache..." && sleep 2
[ -d "$HOME/.local/share/nvim" ] && rm -rf "$HOME/.local/share/nvim"
[ -d "$HOME/.local/state/nvim" ] && rm -rf "$HOME/.local/state/nvim"
[ -d "$HOME/.cache/nvim" ] && rm -rf "$HOME/.cache/nvim"

echo "Which config of Neovim would you like to install?"
echo
read -p "Enter 'l' for LazyNV or 'n' for NvStar: " CONF

if [[ "$CONF" == "l" ]]; then
  git clone "$GITHUB_URL/LazyNV.git" $NVIM_DIR
elif [[ "$CONF" == "n" ]]; then
  git clone "$GITHUB_URL/NvStar.git" $NVIM_DIR
fi

# Remove git related files
# rm -rf "$NVIM_DIR/.git"
rm -rf "$HOME/neovim"
