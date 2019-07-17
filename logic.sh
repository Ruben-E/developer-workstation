. "utils.sh"

cwd="$(cd "$(dirname "$0")" && pwd)"
workstation_dir="$HOME/.workstation"

ask_move_dotfiles() {
    if [ ! -d $workstation_dir ]; then
        mkdir $workstation_dir
        move_dotfiles;

        print_success "$workstation_dir created and dotfiles moved"
    else
        if ask "Replace existing dotfiles in your home directory?" Y; then
            move_dotfiles;
            print_success "Dotfiles moved"
        else
            print_success_muted "Not moving dotfiles";
        fi
    fi
}

move_dotfiles() {
    cp $cwd/.brews $workstation_dir/.brews
    cp $cwd/.casks $workstation_dir/.casks
    cp $cwd/.taps $workstation_dir/.taps
    cp $cwd/.directories $workstation_dir/.directories
    cp $cwd/.fonts $workstation_dir/.fonts
}

add_brew_taps() {
    if [ -e $workstation_dir/.taps ]; then
        for tap in $(<$workstation_dir/.taps); do
            add_brew_tap $tap
        done
    fi
}

add_brew_tap() {
    if [[ ! $(brew tap-info --installed | grep $1) ]]; then
        echo_install "Tapping $1"
		brew tap $1 >/dev/null
		print_in_green "${bold}✓ tapped!${normal}\n"
	else
		print_success_muted "$1 already tapped. Skipped."
    fi
}

install_brews() {
    if [ -e $workstation_dir/.brews ]; then
        for brew in $(<$workstation_dir/.brews); do
            install_brew $brew
        done
    fi
}

install_brew() {
    if [[ ! $(brew list | grep $1) ]]; then
        echo_install "Installing $1"
		brew install $1 >/dev/null
		print_in_green "${bold}✓ installed!${normal}\n"
	else
		print_success_muted "$1 already installed. Skipped."
    fi
}

install_casks() {
    if [ -e $workstation_dir/.casks ]; then
        for cask in $(<$workstation_dir/.casks); do
            install_cask $cask
        done
    fi
}

install_cask() {
    if [[ ! $(brew cask list | grep $1) ]]; then
        echo_install "Installing $1"
		brew cask install $1 --appdir=/Applications >/dev/null
		print_in_green "${bold}✓ installed!${normal}\n"
	else
		print_success_muted "$1 already installed. Skipped."
    fi
}

update_brews() {
    brew update
}

upgrade_brews() {
    brew upgrade
}

upgrade_casks() {
    brew cask upgrade
}

cleanup_homebrew() {
    brew cleanup 2> /dev/null
}

setup_directories() {
    if [ -e $workstation_dir/.directories ]; then
        for directory_s in $(<$workstation_dir/.directories); do
            directory=$(eval echo $directory_s)
            if [ ! -d $directory ]; then
                mkdir -p $directory
                print_success "Directory $directory created"
            else
                print_success_muted "Directory $directory already exists. Skipping"
            fi
        done
    fi
}

check_internet_connection() {
    if [ ping -q -w1 -c1 google.com &>/dev/null ]; then
        print_error "Please check your internet connection";
        exit 0
    else
        print_success "Internet connection";
    fi
}

install_homebrew() {
    if ! [ -x "$(command -v brew)" ]; then
        step "Installing Homebrew…"
        curl -fsS 'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby
        export PATH="/usr/local/bin:$PATH"
        print_success "Homebrew installed!"
    else
        print_success_muted "Homebrew already installed. Skipping."
    fi
}

ask_for_sudo() {

    # Ask for the administrator password upfront.

    sudo -v &> /dev/null

    # Update existing `sudo` time stamp
    # until this script has finished.
    #
    # https://gist.github.com/cowboy/3118588

    # Keep-alive: update existing `sudo` time stamp until script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    print_success "Password cached"

}