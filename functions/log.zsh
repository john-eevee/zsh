function log() {
    local level="${LOG_LEVEL:-debug}"
    local message

    # Define log level hierarchy
    typeset -A levels=( debug 0 info 1 warn 2 error 3 fatal 4 )

    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -l|--level)
                if [[ $# -lt 2 ]]; then
                    print "Usage: log [-l|--level LEVEL] <message>" >&2
                    return 1
                fi
                level="$2"
                shift 2
                ;;
            -h|--help)
                cat << 'EOF'
Simple logger with levels and a global severity filter.

Usage:
log [-l|--level LEVEL] <message>

Options:
-l LEVEL, --level LEVEL   Set the log level (debug, info, warn, error, fatal).
                          Default is 'debug'.

-h, --help                Show this help message.

Environment Variable:
LOG_LEVEL                 Set the global log level threshold (see --level).
                          Messages below this level will not be printed.

Examples:
log -l info This is an informational message.
log --level error An error occurred.
LOG_LEVEL=warn log This debug message will not be shown.
EOF
                return 0
                ;;
            *)
                break
                ;;
        esac
    done

    if [[ $# -eq 0 ]]; then
        print "Usage: log [-l|--level LEVEL] <message>" >&2
        return 1
    fi

    # Validate level
    if [[ ! -v levels[$level] ]]; then
        print "Error: Invalid log level '$level'" >&2
        return 1
    fi

    local threshold_level="${LOG_LEVEL:-debug}"
    if [[ ! -v levels[$threshold_level] ]]; then
        threshold_level="debug"
    fi

    # Check if message should be logged
    (( levels[$level] < levels[$threshold_level] )) && return 0

    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    normal=$(tput sgr0)
    # Log with colors
    case "$level" in
        debug)  printf "[${timestamp}] ${blue}DEBUG${normal}: $*" ;;
        info)   printf "[${timestamp}] ${green}INFO${normal}: $*" ;;
        warn)   printf "[${timestamp}] ${yellow}WARN${normal}: $*" ;;
        error)  printf "[${timestamp}] ${red}ERROR${normal}: $*" >&2 ;;
        fatal)  printf "[${timestamp}] ${red}FATAL${normal}: $*" >&2; return 1 ;;
    esac
}

# Convenience functions
function log_debug()   { log -l debug "$@" }
function log_info()    { log -l info "$@" }
function log_warn()    { log -l warn "$@" }
function log_error()   { log -l error "$@" }
function log_fatal()   { log -l fatal "$@" }
