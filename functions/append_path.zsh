# Append a directory to PATH if it exists and is not already included
function append-path() {
    if [[ -d $1 && ! $PATH == *$1* ]]; then
        export PATH="$PATH:$1"
    fi
}
