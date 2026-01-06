function reload() {
    if [[ -f "$XDG_CONFIG_HOME/zsh/.zshrc" ]]; then
        source "$XDG_CONFIG_HOME/zsh/.zshrc" > /dev/null 2>&1
    fi
}
