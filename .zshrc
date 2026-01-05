
[[ -o interactive ]] || return

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

if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
    export JAVA_HOME="$(mise where java 2>/dev/null)" || {
        local system_java
        system_java="$(readlink -f "$(command -v java)" 2>/dev/null)"
        [[ -n "$system_java" ]] && export JAVA_HOME="${system_java%/bin/java}"
    }
fi
export PROJECT_DIRS=(
    "$HOME/Projects"
    "$HOME/Work"
    "$HOME/Code"
    "$HOME/projects"
    "$HOME/work"
    "$HOME/code"
)
export EDITOR="${EDITOR:-zed}"
path=("$HOME/.local/bin" $path)
typeset -U path
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
else
        setopt PROMPT_SUBST

        git_prompt_info() {
        local git_dir
        git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return

        local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
        local status=""

                if ! git diff-index --quiet HEAD 2>/dev/null; then
            status="%F{red}●%f"          fi

                if [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
            status="${status}%F{yellow}●%f"          fi

                local ahead_behind
        ahead_behind="$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null)"
        if [[ -n "$ahead_behind" ]]; then
            local behind="${ahead_behind%	*}"
            local ahead="${ahead_behind#*	}"
            [[ $ahead -gt 0 ]] && status="${status}%F{green}↑%f"
            [[ $behind -gt 0 ]] && status="${status}%F{red}↓%f"
        fi

        echo "%F{magenta}($branch)%f$status "
    }

        exit_status() {
        [[ $? -eq 0 ]] || echo "%F{red}[$?]%f "
    }

    PS1='%F{blue}%n@%m%f %F{cyan}%~%f $(git_prompt_info)%(?.%F{green}.%F{red})%#%f '
    PS2='%F{yellow}...%f '
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
