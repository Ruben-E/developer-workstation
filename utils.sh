title() {
    local fmt="$1"; shift
    printf "\n✦  ${bold}$fmt${normal}\n└─────────────────────────────────────────────────────○\n" "$@"
}

chapter() {
    local fmt="$1"; shift
    printf "\n✦  ${bold}$((count++)). $fmt${normal}\n└─────────────────────────────────────────────────────○\n" "$@"
}

print_in_red() {
    _print_in_color "$1" 1
}

print_in_green() {
    _print_in_color "$1" 2
}

print_in_yellow() {
    _print_in_color "$1" 3
}

print_in_blue() {
    _print_in_color "$1" 4
}

print_in_purple() {
    _print_in_color "$1" 5
}

print_in_cyan() {
    _print_in_color "$1" 6
}

print_in_white() {
    _print_in_color "$1" 7
}

print_result() {

    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"

}

_print_in_color() {
    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"
}

print_question() {
    print_in_yellow "  [?] $1\n"
}

print_success() {
    print_in_green "  [✓] $1\n"
}

print_success_muted() {
    printf "  ${dim}[✓] $1${reset}\n" "$@"
}

print_muted() {
    printf "  ${dim}$1${reset}\n" "$@"
}

print_warning() {
    print_in_yellow "  [!] $1\n"
}

print_error() {
    print_in_red "  [𝘅] $1 $2\n"
}

echo_install() {
    local fmt="$1"; shift
    printf "  [↓] $fmt " "$@"
}

cwd() {
    return "$(cd "$(dirname "$0")" && pwd)"
}

ask() {
    # https://djm.me/ask
    local prompt default reply

    while true; do

        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo "  [?] $1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}