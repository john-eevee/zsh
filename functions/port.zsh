function port() {
    if [[ $# -eq 0 ]]; then
        print "Usage: port <port_number>" >&2
        return 1
    fi

    lsof -i tcp:"$1"
}
