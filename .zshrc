[[ -o interactive ]] || return
local starttime=$(date +%s.%N)
export GREETING=""
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
if [[ -d "$ANDROID_HOME" ]]; then
    path=(
        "$ANDROID_HOME/cmdline-tools/latest/bin"
        "$ANDROID_HOME/platform-tools"
        "$ANDROID_HOME/emulator"
        "$ANDROID_HOME/tools"
        "$ANDROID_HOME/tools/bin"
        $path
    )
fi

path=("$HOME/.local/bin" $path)
typeset -U path

eval "$(mise activate zsh)"

export JAVA_HOME="$(mise where java 2>/dev/null)" || {
    local system_java
    system_java="$(readlink -f "$(command -v java)" 2>/dev/null)"
    [[ -n "$system_java" ]] && export JAVA_HOME="${system_java%/bin/java}"
}
export PROJECT_DIRS=(
    "$HOME/Projects"
    "$HOME/Work"
    "$HOME/Code"
    "$HOME/projects"
    "$HOME/work"
    "$HOME/code"
)
export EDITOR="${EDITOR:-zed}"
export HISTFILE="$XDG_CACHE_HOME/zsh_history"
mkdir -p "$(dirname "$HISTFILE")"
export HISTSIZE=50000
export SAVEHIST=50000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_FUNCTIONS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
fpath=("$XDG_CONFIG_HOME/zsh/completions" $fpath)
fpath=("$XDG_CONFIG_HOME/zsh/functions" $fpath)
mkdir -p "$XDG_CONFIG_HOME/zsh/completions"
autoload -Uz compinit
if [[ -f "$XDG_CACHE_HOME/zsh/.zcompdump" ]]; then
    compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"
else
    mkdir -p "$XDG_CACHE_HOME/zsh"
    compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"
fi
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'


for file in "$XDG_CONFIG_HOME/zsh/functions"/*.zsh(N); do
    source "$file"
done

[[ -f "$XDG_CONFIG_HOME/zsh/aliases.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/aliases.zsh"


if command -v starship &>/dev/null; then
        eval "$(starship init zsh)"
fi


setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt NO_HUP
setopt CHECK_JOBS
setopt EXTENDED_GLOB
setopt GLOB_COMPLETE
setopt INTERACTIVE_COMMENTS
setopt TRANSIENT_RPROMPT


# Load plugins
for file in "$XDG_CONFIG_HOME/zsh/plugins"/*.zsh(N); do
	source "$file"
done

# Other PATHs
append-path "$HOME/.pub-cache/bin"
append-path "$HOME/.local/share/mise/shims"
. "$HOME/.local/share/../bin/env"

# Calculate and display shell startup time
local endtime=$(date +%s.%N)
local elapsed=$(echo "a=($endtime - $starttime) * 1000; scale=3; a/1" | bc)
print "initialized in ${elapsed}ms"
