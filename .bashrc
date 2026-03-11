# append to the history file, don't overwrite it
shopt -s histappend

# Append immediately
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

# Go hog-wild
. /etc/profile

export PATH="$HOME/.cargo/bin:$PATH"
