#!/usr/bin/env bash
set -e
trap on_sigterm SIGKILL SIGTERM

TEMP_DIR=$(mktemp -d)
COLOR_SCHEME_URL="https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf"
FISHERMAN_URL="https://git.io/fisher"

function set_preferences() {
  echo "Setting some macOS system preferences..."

  # make Library directory visible
  chflags nohidden ~/Library
  # show hidden files
  defaults write com.apple.finder AppleShowAllFiles YES
  # System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
  defaults write -globalDomain "AppleScrollerPagingBehavior" -bool true
  # System Preferences > Dock > Size:
  defaults write com.apple.dock tilesize -int 36
  # System Preferences > Dock > Magnification:
  defaults write com.apple.dock magnification -bool true
  # System Preferences > Dock > Minimize windows into application icon
  defaults write com.apple.dock minimize-to-application -bool true
  # System Preferences > Dock > Automatically hide and show the Dock:
  defaults write com.apple.dock autohide -bool true
  # System Preferences > Dock > Show indicators for open applications
  defaults write com.apple.dock show-process-indicators -bool true
  # System Preferences > Mission Controll > Automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false
  # Finder > Preferences > Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Finder > Preferences > Show wraning before removing from iCloud Drive
  defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
  # Finder > View > As List
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  # Finder > View > Show Path Bar
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true

  echo "Killing affected apps..."
  for app in "Dock" "Finder"; do
    killall "${app}" > /dev/null 2>&1
  done

  echo "Done. Note that some of these changes require a logout/restart to take effect."
  sleep 1
}

#=============== START - Shell specific stuff ==================#

function install_color_scheme() {
    read -p "Do you want to install color scheme for iTerm? (y/N) " -n 1 answer
    echo
    if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
        echo "Downloading color scheme in ${TEMP_DIR}..."

        cd ${TEMP_DIR}
        curl -fsSL ${COLOR_SCHEME_URL} > ./material-design.itermcolors

        echo "iTerm will be opened in 5 seconds, asking to import color scheme (in case, you installed iTerm)"
        echo "Close iTerm when color scheme will be imported"
        sleep 5
        open -W ./material-design.itermcolors

        echo "Color Scheme is installed!"
    else
        echo "Skipping Color Scheme installation..."
    fi

    sleep 1
}

function install_nerd_font() {
    read -p "Do you want to install Hack Nerd Fonts? (y/N) " -n 1 answer
    echo
    if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
        echo "Downloading Hack Nerd Font into ${TEMP_DIR}..."

        cd ${TEMP_DIR}
        curl -fsSL ${NERD_FONT_URL} > ./nerd_font.otf

        echo "Font Manager will be opened in 5 seconds, prompting to install Nerd Font"
        echo "When you will be done with installing Nerd Font, close the Font Manager"
        sleep 5
        open -W ./nerd_font.otf

        echo "Nerd Font is successfully installed!"
    else
        echo "Skipping Nerd Font installation..."
    fi

    sleep 1
}

function install_fish() {
    echo "Trying to detect installed Fish Shell..."

    if ! [ $(which fish) ]; then
        echo "Seems like you don't have Fish Shell installed"
        echo "Fish Shell is required to continue the installation"

        read -p "Do you agree to install it? (y/N) " -n 1 answer
        echo
        if [ ${answer} != "y" ]; then
            exit 1
        fi

        echo "Installing Fish Shell..."
        echo "The script will ask you the password for sudo 2 times:"
        echo
        echo "1) When adding fish shell into /etc/shells via tee"
        echo "2) When changing your default shell via chsh -s"

        brew install fish
    else
        echo "You already have Fish Shell installed"
        echo "Just to be sure, that this is your default shell, I'm going to call chsh..."
    fi

    echo "$(command -v fish)" | sudo tee -a /etc/shells

    echo "Fish installed!"

    sleep 1
}

function install_fisherman() {
    echo "Fisherman is required for the installation"

    read -p "Do you agree to install it? (y/N) " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
        exit 1
    fi

    echo "Installing Fisherman..."

    curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs ${FISHERMAN_URL}

    echo "Fisherman installed!"

    sleep 1
}

function install_fisherman_plugins_and_themes() {
    echo "Some of the Fisherman plugins requires external dependencies to be installed via Homebrew..."

    read -p "Do you want to install Themes and Plugins for Fisherman? (y/N) " -n 1 answer
    echo
    if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
        echo "Installing Themes and Plugins..."

        fisher add oh-my-fish/theme-bobthefish

        echo "Themes and Plugins installed!"
    else
        echo "Skipping Themes and Plugins installation..."
    fi

    sleep 1
}

function post_install() {
    echo
    echo
    echo "Setup was successfully done"
    echo "Do not forgot to make two simple, but manual things:"
    echo
    echo "1) Open iTerm -> Preferences -> Profiles -> Colors -> Presets and apply color preset"
    echo "2) Open iTerm -> Preferences -> Profiles -> Text -> Font and apply font (for non-ASCII as well)"
    echo
    echo "Happy Coding!"

    exit 0
}

function on_sigterm() {
    echo
    echo -e "Wow... Something serious happened!"
    exit 1
}

set_preferences
install_color_scheme
install_nerd_font
install_fish
install_fisherman
install_fisherman_plugins_and_themes
post_install
