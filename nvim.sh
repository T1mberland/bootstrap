#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

# ============================================================
# Configuration
# ============================================================

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
OPT_DIR="$PREFIX/opt"
NVIM_DIR="$OPT_DIR/nvim"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

# stable / nightly / v0.12.4 のようなタグを指定可能
NVIM_CHANNEL="${NVIM_CHANNEL:-stable}"

FORCE_CONFIG=0

# ============================================================
# Helpers
# ============================================================

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

usage() {
  cat <<'EOF'
Usage:
  bootstrap.sh [options]

Options:
  --force-config   既存の init.lua をバックアップして置き換える
  -h, --help       ヘルプを表示

Environment variables:
  PREFIX           インストール先。デフォルト: ~/.local
  NVIM_CHANNEL     stable, nightly, または v0.12.4 など
EOF
}

# ============================================================
# Arguments
# ============================================================

while (($# > 0)); do
  case "$1" in
  --force-config)
    FORCE_CONFIG=1
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    die "Unknown argument: $1"
    ;;
  esac
  shift
done

# ============================================================
# Requirements
# ============================================================

command_exists tar || die "'tar' is required."

if command_exists curl; then
  download() {
    curl \
      --fail \
      --location \
      --silent \
      --show-error \
      --retry 3 \
      "$1" \
      --output "$2"
  }
elif command_exists wget; then
  download() {
    wget --quiet --output-document="$2" "$1"
  }
else
  die "'curl' or 'wget' is required."
fi

# ============================================================
# Platform detection
# ============================================================

os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
Linux)
  platform="linux"
  ;;
Darwin)
  platform="macos"
  ;;
*)
  die "Unsupported operating system: $os"
  ;;
esac

case "$arch" in
x86_64 | amd64)
  architecture="x86_64"
  ;;
arm64 | aarch64)
  architecture="arm64"
  ;;
*)
  die "Unsupported architecture: $arch"
  ;;
esac

archive="nvim-${platform}-${architecture}.tar.gz"
extracted_dir="nvim-${platform}-${architecture}"

case "$NVIM_CHANNEL" in
stable)
  download_url="https://github.com/neovim/neovim/releases/latest/download/$archive"
  ;;
nightly)
  download_url="https://github.com/neovim/neovim/releases/download/nightly/$archive"
  ;;
*)
  download_url="https://github.com/neovim/neovim/releases/download/$NVIM_CHANNEL/$archive"
  ;;
esac

# ============================================================
# Install Neovim
# ============================================================

tmp_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$tmp_dir"
}

trap cleanup EXIT

mkdir -p "$BIN_DIR" "$OPT_DIR"

log "Downloading Neovim: $NVIM_CHANNEL"
log "$download_url"

download "$download_url" "$tmp_dir/$archive"

log "Extracting Neovim"
tar -xzf "$tmp_dir/$archive" -C "$tmp_dir"

[[ -d "$tmp_dir/$extracted_dir" ]] ||
  die "Expected directory not found after extraction: $extracted_dir"

# 途中で失敗したときに既存のNeovimをなるべく残す
staging_dir="$OPT_DIR/nvim.new"

rm -rf "$staging_dir"
mv "$tmp_dir/$extracted_dir" "$staging_dir"

rm -rf "$NVIM_DIR"
mv "$staging_dir" "$NVIM_DIR"

ln -sfn "$NVIM_DIR/bin/nvim" "$BIN_DIR/nvim"

log "Installed Neovim to $NVIM_DIR"

# ============================================================
# PATH
# ============================================================

profile_file="$HOME/.profile"
path_marker="# Added by bootstrap.sh"
path_line="export PATH=\"$BIN_DIR:\$PATH\""

touch "$profile_file"

if ! grep -Fq "$path_marker" "$profile_file"; then
  cat >>"$profile_file" <<EOF

$path_marker
$path_line
EOF

  log "Added $BIN_DIR to PATH in $profile_file"
fi

# このスクリプト内でも即座に利用可能にする
export PATH="$BIN_DIR:$PATH"

# ============================================================
# Neovim config
# ============================================================

NVIM_CONFIG_REPO="${NVIM_CONFIG_REPO:-T1mberland/init.lua.light}"
NVIM_CONFIG_BRANCH="${NVIM_CONFIG_BRANCH:-main}"

install_nvim_config() {
  local archive_url
  local archive_file
  local extracted_dir
  local new_config_dir

  archive_url="https://github.com/${NVIM_CONFIG_REPO}/archive/refs/heads/${NVIM_CONFIG_BRANCH}.tar.gz"
  archive_file="$tmp_dir/nvim-config.tar.gz"
  extracted_dir="$tmp_dir/init.lua.light-${NVIM_CONFIG_BRANCH}"
  new_config_dir="$tmp_dir/nvim-config"

  log "Downloading Neovim config"
  log "$archive_url"

  download "$archive_url" "$archive_file"

  mkdir -p "$new_config_dir"

  tar \
    -xzf "$archive_file" \
    --strip-components=1 \
    -C "$new_config_dir"

  if [[ ! -f "$new_config_dir/init.lua" ]]; then
    die "The config repository does not contain init.lua at its root."
  fi

  mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"

  if [[ -e "$NVIM_CONFIG_DIR" ]]; then
    backup_dir="${NVIM_CONFIG_DIR}.backup.$(date '+%Y%m%d-%H%M%S')"

    mv "$NVIM_CONFIG_DIR" "$backup_dir"

    warn "Existing Neovim config backed up to:"
    warn "$backup_dir"
  fi

  mv "$new_config_dir" "$NVIM_CONFIG_DIR"

  log "Installed Neovim config to $NVIM_CONFIG_DIR"
}

if [[ ! -e "$NVIM_CONFIG_DIR" ]]; then
  install_nvim_config
elif ((FORCE_CONFIG)); then
  install_nvim_config
else
  log "Existing Neovim config found; leaving it unchanged"
  log "Use --force-config to replace it"
fi

# ============================================================
# Finish
# ============================================================

printf '\n'
log "Bootstrap complete"
nvim --version | head -n 1

printf '\n'
printf 'Reconnect SSH or run:\n'
printf '  source ~/.profile\n'
printf '\n'
printf 'Then start Neovim with:\n'
printf '  nvim\n'
