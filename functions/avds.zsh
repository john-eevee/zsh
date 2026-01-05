function avds() {
    if command -v emulator &>/dev/null; then
        emulator -list-avds
    else
        print "Error: emulator command not found. Is Android SDK properly installed?" >&2
        return 1
    fi
}
