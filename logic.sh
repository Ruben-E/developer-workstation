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
    cp $cwd/.apps $workstation_dir/.apps
    cp $cwd/.directories $workstation_dir/.directories
    cp $cwd/.fonts $workstation_dir/.fonts
}

add_brew_taps() {
    if [ -e $workstation_dir/.taps ]; then
        taps=$(brew tap-info --installed)
        for tap in $(<$workstation_dir/.taps); do
            if [[ ! $(echo $taps | grep $tap) ]]; then
                echo_install "Tapping $tap"
                brew tap $tap >/dev/null
                print_success "$tap tapped!"
            else
                print_success_muted "$tap already tapped. Skipped."
            fi
        done
    fi
}
install_brews() {
    if [ -e $workstation_dir/.brews ]; then
        installed_brews=$(brew list)
        for brew in $(<$workstation_dir/.brews); do
            if [[ ! $(echo $installed_brews | grep $brew) ]]; then
                echo_install "Installing $brew"
                brew install $brew >/dev/null
                print_success "$brew installed!"
            else
                print_success_muted "$brew already installed. Skipped."
            fi
        done
    fi
}

install_casks() {
    if [ -e $workstation_dir/.casks ]; then
        installed_casks=$(brew cask list)
        for cask in $(<$workstation_dir/.casks); do
            if [[ ! $(echo $installed_casks | grep $cask) ]]; then
                echo_install "Installing $cask"
                brew cask install $cask --appdir=/Applications >/dev/null
                print_success "$cask installed!"
            else
                print_success_muted "$cask already installed. Skipped."
            fi
        done
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

mas_setup() {
    if mas account > /dev/null; then
        return 0
    else
        return 1
    fi
}

install_appstore_apps() {
    if [ -e $workstation_dir/.apps ]; then
        if [ -x mas ]; then
            print_warning "Tool mas not installed. Installing"
            echo_install "Installing mas"
            brew install mas >/dev/null
            print_success "mas installed!"
        fi

        if mas_setup; then
            installed_apps=$(mas list)
            for app in $(<$workstation_dir/.apps); do
                KEY="${app%%::*}"
                VALUE="${app##*::}"
                if [[ ! $(echo $installed_apps | grep $KEY) ]]; then
                    echo_install "Installing $VALUE"
                    mas install $KEY >/dev/null
                    print_success "$VALUE installed!"
                else
                    print_success_muted "$VALUE already installed. Skipped."
                fi
            done
        else
            print_warning "Please signin to App Store first. Skipping."
        fi
    fi
}

setup_directories() {
    if [ -e $workstation_dir/.directories ]; then
        for directory_s in $(<$workstation_dir/.directories); do
            directory=$(eval echo $directory_s)
            if [ ! -d $directory ]; then
                mkdir -p $directory
                print_success "$directory created!"
            else
                print_success_muted "Directory $directory already exists. Skipping"
            fi
        done
    fi
}

install_fonts() {
    if [ -e $workstation_dir/.fonts ]; then
        release=$(curl -L -s -H 'Accept: application/json' https://github.com/ryanoasis/nerd-fonts/releases/latest)
        version=$(echo $release | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
        for font in $(<$workstation_dir/.fonts); do
            if [ ! -d ~/Library/Fonts/$font ]; then
                echo_install "Installing $font"
                wget -P ~/Library/Fonts https://github.com/ryanoasis/nerd-fonts/releases/download/$NERDFONTS_VERSION/$font.zip --quiet;unzip -q ~/Library/Fonts/$font -d ~/Library/Fonts/$font
                print_success "$1 installed"
            else
                print_success_muted "$font already installed. Skipped."
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