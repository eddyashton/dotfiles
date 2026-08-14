#!/usr/bin/env bash

set -euo pipefail

dotfiles_dir="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
  git rev-parse --show-toplevel
)"

link_path() {
  local source_path="$1"
  local destination="$2"

  mkdir -p "$(dirname -- "$destination")"

  if [ -e "$destination" ] && [ ! -L "$destination" ]; then
    printf 'Refusing to replace non-symlink: %s\n' "$destination" >&2
    return 1
  fi

  rm -f -- "$destination"
  ln -s -- "$source_path" "$destination"
}

# Generic, cross-harness agent configuration.
link_path \
  "$dotfiles_dir/.agents" \
  "$HOME/.agents"

# Harness-specific adapters to the canonical personal instructions.
link_path \
  "$dotfiles_dir/.agents/AGENTS.md" \
  "$HOME/.copilot/copilot-instructions.md"

link_path \
  "$dotfiles_dir/.agents/AGENTS.md" \
  "$HOME/.codex/AGENTS.md"

link_path \
  "$dotfiles_dir/.agents/AGENTS.md" \
  "$HOME/.config/opencode/AGENTS.md"

# Personal Agent Host lifecycle commands.
chmod +x -- "$dotfiles_dir/bin/agent-host"
for command_name in \
  agent-host \
  start-agent-host \
  stop-agent-host \
  restart-agent-host \
  agent-host-status
do
  link_path \
    "$dotfiles_dir/bin/agent-host" \
    "$HOME/.local/bin/$command_name"
done

printf 'Dotfiles installed from %s\n' "$dotfiles_dir"