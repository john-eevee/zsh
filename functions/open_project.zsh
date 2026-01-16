function open_project() {
    # Default search paths
    local search_paths=("${PROJECT_DIRS[@]}")

    # Use custom paths if provided
    if [[ $# -gt 0 ]]; then
        log_info "Using custom search paths: $@"
        search_paths=("$@")
    fi

    # Catppuccin Mocha colors
    local colors=(
        '#1e1e2e:base'
        '#181825:mantle'
        '#313244:surface0'
        '#45475a:surface1'
        '#585b70:surface2'
        '#cdd6f4:text'
        '#f5e0dc:rosewater'
        '#b4befe:lavender'
        '#f38ba8:red'
        '#fab387:peach'
        '#f9e2af:yellow'
        '#a6e3a1:green'
        '#94e2d5:teal'
        '#89b4fa:blue'
        '#cba6f7:mauve'
        '#f2cdcd:flamingo'
    )

    # Filter to valid paths only
    local valid_paths=()
    local path_dir
    for path_dir in "${search_paths[@]}"; do
        [[ -d "$path_dir" ]] && valid_paths+=("$path_dir")
    done

    if (( ${#valid_paths[@]} == 0 )); then
        valid_paths=("$HOME")
    fi

    # FZF options with Catppuccin colors
    local fzf_opts=(
        --reverse
        --border=rounded
        --prompt='Go to > '
        --pointer='>'
        --marker='>'
        --height=40%
        '--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8'
        '--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc'
        '--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
    )

    if command -v eza &>/dev/null; then
        fzf_opts+=(
            '--preview=eza --tree --level=2 --icons --git --group-directories-first --color=always {1}'
            '--preview-window=right:60%:border-left'
        )
    fi

    # Find git repos and select with fzf
    local result
    result=$(
        find "${valid_paths[@]}" -maxdepth 3 -type d -name ".git" 2>/dev/null |
        xargs -I {} dirname {} |
        fzf "${fzf_opts[@]}"
    )

    if [[ -z "$result" ]]; then
        return 1
    fi

    # Change directory
    builtin cd "$result" || return $?

    # Run post-cd actions
    _post_project_cd

    # Open in editor
    local editor="${EDITOR:-zed}"
    "$editor" .
    log_info "Opened project at $result in $editor"
}

# Actions to perform after changing to a project directory
function _post_project_cd() {
    local project_type
    project_type=$(_get_project_type)

    case "$project_type" in
        node)
            (( ${+functions[on_node_callback]} )) && on_node_callback
            ;;
        java-maven)
            (( ${+functions[on_java_callback]} )) && on_java_callback
            ;;
        java-gradle)
            (( ${+functions[on_java_callback]} )) && on_java_callback
            ;;
        python)
            (( ${+functions[on_python_callback]} )) && on_python_callback
            ;;
        elixir)
            (( ${+functions[on_elixir_callback]} )) && on_elixir_callback
            ;;
        flutter)
            (( ${+functions[on_flutter_callback]} )) && on_flutter_callback
            ;;
    esac
}

# Determine project type by checking for markers
function _get_project_type() {
    case true in
        *([[ -f "package.json" ]]))        echo "node" ;;
        *([[ -f "pom.xml" ]]))             echo "java-maven" ;;
        *([[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]])) echo "java-gradle" ;;
        *([[ -f "setup.py" ]] || [[ -f "pyproject.toml" ]])) echo "python" ;;
        *([[ -f "mix.exs" ]]))             echo "elixir" ;;
        *([[ -f "pubspec.yaml" ]]))        echo "flutter" ;;
        *)                                 echo "unknown" ;;
    esac
}
