function mkcd() {
    if [[ $# -eq 0 ]]; then
        print "Usage: mkcd <directory>" >&2
        return 1
    fi

    mkdir -p "$1" && builtin cd "$1"
}
