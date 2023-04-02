#!/bin/bash

if [ ! -x "$(command -v nvim)" ]; then
  echo "${red}Neovim not Installed${reset}"
  echo "${yellow}Installing Neovim binary..."

  echo "Choose between : "
  select NVIM_VERSION in "Stable" "Nightly"; do
    if [ $NVIM_VERSION ]; then
      break
    fi
  done
  printf "\nInstalling %s version...\n" "$NVIM_VERSION"

  mkdir "$HOME/neovim"
  cd "$HOME/neovim" || exit

  if [[ "$NVIM_VERSION" == "Stable" ]]; then
    curl -sLO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    sudo chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract
    ./squashfs-root/AppRun --version
    sudo mv squashfs-root /
    sudo mv /squashfs-root/AppRun /usr/bin/nvim
  else
    git clone --quiet --depth 1 --branch nightly https://github.com/neovim/neovim.git
    cd neovim || exit
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
  fi
else
  echo "${green}Neovim is installed. Installing configs...${reset}"
fi

## Back up current config
[ -d $NVIM_DIR ] && mv $NVIM_DIR "$NVIM_DIR.backup"

## Optional but recommended
[ -d "$HOME/.local/share/nvim" ] && rm -rf "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.backup"
[ -d "$HOME/.local/state/nvim" ] && rm -rf "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.backup"
[ -d "$HOME/.cache/nvim" ] && rm -rf "$HOME/.cache/nvim" "$HOME/.cache/nvim.backup"

git clone "$GITHUB_URL/NvStar.git" $NVIM_DIR

# Remove git related files
rm -rf "$NVIM_DIR/.git"
rm -rf "$HOME/neovim"
