# append to the history file, don't overwrite it
shopt -s histappend

# Append immediately
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

# Go hog-wild
. /etc/profile

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if [ "${CODESPACES:-}" = "true" ] &&
  command -v start-agent-host >/dev/null 2>&1
then
  mkdir -p "$HOME/.cache"
  start-agent-host >>"$HOME/.cache/agent-host-start.log" 2>&1 &
fi
