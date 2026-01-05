function alarm() {
    local OPTIND opt
    local time count message infinite=0

    # Parse arguments using getopts
    while getopts "t:c:m:i" opt; do
        case "$opt" in
            t)  time="$OPTARG" ;;
            c)  count="$OPTARG" ;;
            m)  message="$OPTARG" ;;
            i)  infinite=1 ;;
            *)  print "Usage: alarm -t <time> [-c <count>] [-m <message>] [-i]" >&2; return 1 ;;
        esac
    done

    # Set defaults
    time="${time:?alarm: -t/time is required}"
    count="${count:-1}"
    message="${message:-Time's up!}"

    print "Setting alarm for every $time seconds for $count times. Message: '$message'"

    if (( infinite )); then
        while true; do
            _alarm_internal "$time" "$message"
        done
    else
        for ((i = 1; i <= count; i++)); do
            _alarm_internal "$time" "$message"
        done
    fi
}

# Internal function to handle single alarm
function _alarm_internal() {
    local time=$1
    local message=$2

    sleep "$time" || return $?
    printf "\a"  # Bell character

    if command -v notify-send &>/dev/null; then
        notify-send "Alarm" "$message"
    else
        print "Alarm: $message"
    fi
}
