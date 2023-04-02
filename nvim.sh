#!/bin/bash

echo "Which version of Neovim would you like to install?"
echo "Enter 's' for stable or 'n' for nightly:"
read VERSION

if [[ "$VERSION" == "s" ]]; then
  echo "Installing stable version of Neovim..."
  wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
  chmod u+x nvim.appimage
  sudo mv nvim.appimage /usr/local/bin/nvim
elif [[ "$VERSION" == "n" ]]; then
  echo "Installing nightly version of Neovim..."
  wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
  chmod u+x nvim.appimage
  sudo mv nvim.appimage /usr/local/bin/nvim
else
  echo "Invalid input. Please enter 's' for stable or 'n' for nightly."
  exit 1
fi

echo "Neovim installation complete!"
