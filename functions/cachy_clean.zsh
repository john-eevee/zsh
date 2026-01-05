function cachy-clean() {
    if ! command -v paccache &>/dev/null; then
        log_error "Please install 'pacman-contrib' to use paccache."
        return 1
    fi

    sudo paccache -r -k 2
    log_info "Package cache cleaned (kept last 2 versions)."
}
