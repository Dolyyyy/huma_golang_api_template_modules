#!/usr/bin/env bash
set -euo pipefail

if [ -t 1 ]; then
  C_RESET="\033[0m"
  C_RED="\033[31m"
  C_GREEN="\033[32m"
  C_YELLOW="\033[33m"
  C_CYAN="\033[36m"
  C_BOLD="\033[1m"
else
  C_RESET=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_CYAN=""
  C_BOLD=""
fi

info() { printf "%b\n" "${C_CYAN}[INFO]${C_RESET} $*"; }
ok() { printf "%b\n" "${C_GREEN}[OK]${C_RESET} $*"; }
warn() { printf "%b\n" "${C_YELLOW}[WARN]${C_RESET} $*"; }
err() {
  printf "%b\n" "${C_RED}[ERR]${C_RESET} $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif need_cmd sudo; then
    sudo "$@"
  else
    err "root or sudo required to install missing packages"
  fi
}

try_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif need_cmd sudo; then
    sudo "$@"
  else
    return 1
  fi
}

install_git() {
  if need_cmd git; then
    info "git already installed"
    return
  fi

  info "git not found, installing..."

  if need_cmd apt-get; then
    as_root apt-get update
    as_root apt-get install -y git ca-certificates
  elif need_cmd dnf; then
    as_root dnf install -y git ca-certificates
  elif need_cmd yum; then
    as_root yum install -y git ca-certificates
  elif need_cmd apk; then
    as_root apk add --no-cache git ca-certificates
  elif need_cmd zypper; then
    as_root zypper --non-interactive install git ca-certificates
  elif need_cmd pacman; then
    as_root pacman -Sy --noconfirm git ca-certificates
  elif need_cmd brew; then
    brew install git
  else
    err "no supported package manager found to install git"
  fi
}

install_git

GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"

if [ -d "$GOENV_ROOT/.git" ]; then
  info "goenv already exists at $GOENV_ROOT"
else
  info "cloning goenv into $GOENV_ROOT"
  git clone https://github.com/go-nv/goenv.git "$GOENV_ROOT"
fi

RC="$HOME/.bashrc"
if [ -n "${ZSH_VERSION:-}" ]; then
  RC="$HOME/.zshrc"
fi
touch "$RC"

add_line() {
  local line="$1"
  if grep -qxF "$line" "$RC"; then
    warn "already present in $RC: $line"
  else
    printf "%s\n" "$line" >>"$RC"
    info "added to $RC: $line"
  fi
}

add_line 'export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"'
add_line 'export PATH="$GOENV_ROOT/bin:$PATH"'
add_line 'eval "$(goenv init -)"'

# Best effort: make goenv available immediately.
export GOENV_ROOT
export PATH="$GOENV_ROOT/bin:$PATH"
if need_cmd goenv; then
  eval "$(goenv init -)" >/dev/null 2>&1 || true
fi

# When installer is executed via "curl|bash", parent shell env cannot be changed.
# Create a launcher in /usr/local/bin so "goenv" is usually available right away.
if ! need_cmd goenv && [ -x "$GOENV_ROOT/bin/goenv" ]; then
  if try_as_root mkdir -p /usr/local/bin && try_as_root ln -sf "$GOENV_ROOT/bin/goenv" /usr/local/bin/goenv; then
    info "created launcher: /usr/local/bin/goenv"
  else
    warn "could not create /usr/local/bin/goenv launcher (no root/sudo)"
  fi
fi

if need_cmd goenv; then
  version="$(goenv --version 2>/dev/null || true)"
  if [ -n "$version" ]; then
    ok "goenv installed and available now (${version})"
  else
    ok "goenv installed and available now"
  fi
else
  ok "goenv installed and configured"
  warn "goenv command is not available in current shell yet"
fi

printf "%b\n" "${C_BOLD}Next steps${C_RESET}"
info "Verify now: goenv --version"
info "If command is not found yet: source $RC"
info "Fallback: exec \$SHELL"

# Default behavior: open a fresh interactive login shell at the end.
# This is especially useful for "curl|bash" or "wget|bash" invocations.
AUTO_SHELL="${GOENV_INSTALL_AUTO_SHELL:-1}"
if [ "$AUTO_SHELL" = "1" ]; then
  if [ -e /dev/tty ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
    NEW_SHELL="${SHELL:-/bin/bash}"
    info "opening a new login shell now (${NEW_SHELL} -il)"
    exec "$NEW_SHELL" -il < /dev/tty > /dev/tty 2>&1
  else
    warn "cannot open an interactive shell automatically (no /dev/tty)"
  fi
else
  info "auto shell restart disabled (GOENV_INSTALL_AUTO_SHELL=0)"
fi
