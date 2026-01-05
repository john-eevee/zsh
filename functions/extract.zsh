function extract() {
    local file="$1"
    local opts=("${@:2}")  # Capture remaining arguments

    if [[ ! -f "$file" ]]; then
        print "Error: '$file' is not a valid file" >&2
        return 1
    fi

    case "$file" in
        *.tar.bz2)  tar xjf "$file" "${opts[@]}" ;;
        *.tar.gz)   tar xzf "$file" "${opts[@]}" ;;
        *.bz2)      bunzip2 "$file" "${opts[@]}" ;;
        *.rar)      unrar x "$file" "${opts[@]}" ;;
        *.gz)       gunzip "$file" "${opts[@]}" ;;
        *.tar)      tar xf "$file" "${opts[@]}" ;;
        *.tbz2)     tar xjf "$file" "${opts[@]}" ;;
        *.tgz)      tar xzf "$file" "${opts[@]}" ;;
        *.zip)      unzip "$file" "${opts[@]}" ;;
        *.Z)        uncompress "$file" "${opts[@]}" ;;
        *.7z)       7z x "$file" "${opts[@]}" ;;
        *.xz)       unxz "$file" "${opts[@]}" ;;
        *)
            print "Error: '$file' cannot be extracted via extract()" >&2
            return 1
            ;;
    esac
}
