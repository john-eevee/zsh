function extract_all() {
    local target_dir="${1:-.}"

    # Validation
    if [[ ! -d "$target_dir" ]]; then
        log_error "Directory '$target_dir' not found."
        return 1
    fi

    if ! (( ${+functions[extract]} )); then
        log_error "Function 'extract' is missing. Please add it first."
        return 1
    fi

    # Define extensions to search for
    local exts=(tar bz2 rar gz zip Z tbz2 tgz 7z xz)
    local count=0

    # Build find pattern
    local find_pattern=""
    for ext in "${exts[@]}"; do
        find_pattern="$find_pattern -o -name *.$ext"
    done
    find_pattern="${find_pattern# -o }"

    log_info "Hunting for archives in '$target_dir'..."

    # Find and extract archives
    while IFS= read -r archive; do
        ((count++))
        log_info "Extracting: $archive"

        if extract "$archive"; then
            log_success "Extracted $archive"
        else
            log_error "Failed to extract $archive"
        fi
    done < <(find "$target_dir" -type f \( $find_pattern \))

    log_success "Extracted $count archive(s)"
}
