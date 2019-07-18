. "utils.sh"
. "logic.sh"

# 
# Prepare
# 
title "Preparing"

chapter "Checking internet connection..."
check_internet_connection

chapter "Caching password..."
ask_for_sudo

chapter "Move dotfiles"
ask_move_dotfiles

# 
# Homebrew
# 
title "Homebrew"

chapter "Install homebrew"
install_homebrew

chapter "Add taps"
add_brew_taps

chapter "Update brews"
update_brews

chapter "Install brews"
install_brews

chapter "Upgrade brews"
upgrade_brews

chapter "Install casks"
install_casks

chapter "Upgrade casks"
upgrade_casks

chapter "Cleanup homebrew"
cleanup_homebrew

# 
# Apps
# 
title "AppStore apps"

chapter "Install AppStore apps"
install_appstore_apps

# 
# Directories
# 
title "Directories"
setup_directories

# 
# Fonts
# 
title "Fonts"
install_fonts