#!/bin/sh

tmpdir=$(mktemp -d)
tmppath="${tmpdir}/nvim"
nvimpath="/opt/nvim-linux-x86_64/bin/nvim"
arch=$(uname -m)

case "$arch" in
aarch64 | arm64)
  echo "Downloading https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage to ${tmppath}"
  curl -sSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage -o $tmppath
  ;;
x86_64 | amd64)
  echo "Downloading https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage to ${tmppath}"
  curl -sSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage -o $tmppath
  ;;
*)
  ecoh "Unknown architecture: $arch"
  exit 1
  ;;
esac

chmod +x $tmppath

echo "Moving ${tmppath} to ${nvimpath}."
sudo mv $tmppath $nvimpath
