#!/usr/bin/env bash
#title          :install.sh
#description    :This script will set up my machine.
#author         :ferdinand-swoboda
#date           :2019-01-23
#version        :0.2
#usage          :bash <(curl -s https://raw.githubusercontent.com/ferdinand-swoboda/setup/master/install.sh)
#bash_version   :3.2.57(1)-release
#===================================================================================

set -e
trap on_sigterm SIGKILL SIGTERM

TEMP_DIR=$(mktemp -d)
HOMEBREW_INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/master/install"
COLOR_SCHEME_URL="https://raw.githubusercontent.com/MartinSeeler/iterm2-material-design/master/material-design-colors.itermcolors"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono.ttf"
FISHERMAN_URL="https://git.io/fisher"
RESET_COLOR="\033[0m"
RED_COLOR="\033[0;31m"
GREEN_COLOR="\033[0;32m"
BLUE_COLOR="\033[0;34m"

function reset_color() {
    echo -e "${RESET_COLOR}\c"
}

function red_color() {
    echo -e "${RED_COLOR}\c"
}

function green_color() {
    echo -e "${GREEN_COLOR}\c"
}

function blue_color() {
    echo -e "${BLUE_COLOR}\c"
}

function separator() {
    green_color
    echo "#=============================STEP FINISHED=============================#"
    reset_color
}

function hello() {
    blue_color
    echo "This script will guide you through installing all the required dependencies for my basic machine setup including customized Fish shell, app configs and Homebrew apps."
    echo "However, it will not download SSH or GPG keys or my data vaults."
    echo "Furthermore, it will not install anything, without direct agreement."

    green_color
    read -p "Do you want to proceed with installation? (y/N) " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
        exit 1
    fi

    reset_color
}

function install_command_line_tools() {
    blue_color
    echo "Trying to detect installed Command Line Tools..."

    if ! [ $(xcode-select -p) ]; then
        blue_color
        echo "You don't have Command Line Tools installed"
        echo "They are required to proceed with installation"

        green_color
        read -p "Do you agree to install Command Line Tools? (y/N) " -n 1 answer
        echo
        if [ ${answer} != "y" ]; then
            exit 1
        fi

        blue_color
        echo "Installing Command Line Tools..."
        echo "Please, wait until Command Line Tools will be installed, before continue"
        echo "I can't wait for its installation from the script, so continue..."

        xcode-select --install
    else
        blue_color
        echo "Seems like you have installed Command Line Tools, so skipping..."
    fi

    reset_color
    separator
    sleep 1
}

function install_homebrew() {
    blue_color
    echo "Trying to detect installed Homebrew..."

    if ! [ $(which brew) ]; then
        blue_color
        echo "Seems like you don't have Homebrew installed"
        echo "We need it for completing the installation"

        green_color
        read -p "Do you agree to proceed with Homebrew installation? (y/N) " -n 1 answer
        echo
        if [ ${answer} != "y" ]; then
            exit 1
        fi

        blue_color
        echo "Installing Homebrew..."

        ruby -e "$(curl -fsSL ${HOMEBREW_INSTALLER_URL})"
        brew update
        brew upgrade

        green_color
        echo "Homebrew installed!"
    else
        blue_color
        echo "You already have Homebrew installed, so skipping..."
    fi

    reset_color
    separator
    sleep 1
}

function install_git() {
  blue_color
  echo "Trying to detect Git..."

  if ! [ $(which git) ]; then
      blue_color
      echo "Seems like you don't have Git installed"

      green_color
      read -p "Do you agree to proceed with Git installation? (y/N) " -n 1 answer
      echo
      if [ ${answer} != "y" ]; then
          exit 1
      fi

      blue_color
      echo "Installing Git..."

      brew install git

      green_color
      echo "Git installed!"
  else
      blue_color
      echo "You already have Git installed, so skipping..."
  fi

  reset_color
  separator
  sleep 1
}

function clone_setup_project() {
  blue_color
  echo "Cloning setup project?"
  echo "We need it to complete the installation of apps"

  green_color
  read -p "Do you agree to download the setup files? (y/N) " -n 1 answer
  echo
  if [ ${answer} != "y" ]; then
      exit 1
  fi

  blue_color
  echo "Cloning setup project into projects directory..."

  mkdir ~/projects
  git clone git@github.com:ferdinand-swoboda/setup.git ~/projects/setup

  green_color
  echo "Project cloned!"

  reset_color
  separator
  sleep 1
}

function link_config_files() {
  blue_color
  echo "Linking config files?"

  green_color
  read -p "Do you want to link the config files? (y/N) " -n 1 answer
  echo
  if [ ${answer} != "y" ]; then
      blue_color
      echo "Skipping config file linking..."
  else
    ln -s -f ../projects/setup/.gitconfig ~/.gitconfig
    ln -s -f ../projects/setup/.ssh/config ~/.ssh/config
    ln -s -f ../projects/setup/.unison/default.prf ~/.unison/default.prf
    ln -s -f ../projects/setup/.unison/home-to-onedrive.prf ~/.unison/home-to-onedrive.prf
    ln -s -f ../projects/setup/.unison/home-to-google.prf ~/.unison/home-to-google.prf
    ln -s -f ../projects/setup/.unison/home-to-dropbox.prf ~/.unison/home-to-dropbox.prf

    green_color
    echo "Config files (symbolically) linked!"
  fi

  reset_color
  separator
  sleep 1
}

function install_apps() {
    blue_color
    echo "Installing/upgrading apps from Brewfile"

    green_color
    read -p "Do you agree to install all apps in the Brewfile? (y/N) " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
        exit 1
    fi

    brew bundle install --file=~/projects/setup/Brewfile

    green_color
    echo "Apps installed!"

    reset_color
    separator
    sleep 1
}

function set_preferences() {
  blue_color
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

  green_color
  echo "Done. Note that some of these changes require a logout/restart to take effect."

  reset_color
  separator
  sleep 1
}

#=============== START - Shell specific stuff ==================#

function install_color_scheme() {
    green_color
    read -p "Do you want to install color scheme for iTerm? (y/N) " -n 1 answer
    echo
    if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
        blue_color
        echo "Downloading color scheme in ${TEMP_DIR}..."

        cd ${TEMP_DIR}
        curl -fsSL ${COLOR_SCHEME_URL} > ./material-design.itermcolors

        blue_color
        echo "iTerm will be opened in 5 seconds, asking to import color scheme (in case, you installed iTerm)"
        echo "Close iTerm when color scheme will be imported"
        sleep 5
        open -W ./material-design.itermcolors

        green_color
        echo "Color Scheme is installed!"
    else
        blue_color
        echo "Skipping Color Scheme installation..."
    fi

    reset_color
    separator
    sleep 1
}

function install_nerd_font() {
    green_color
    read -p "Do you want to install Hack Nerd Fonts? (y/N) " -n 1 answer
    echo
    if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
        blue_color
        echo "Downloading Hack Nerd Font into ${TEMP_DIR}..."

        cd ${TEMP_DIR}
        curl -fsSL ${NERD_FONT_URL} > ./nerd_font.otf

        blue_color
        echo "Font Manager will be opened in 5 seconds, prompting to install Nerd Font"
        echo "When you will be done with installing Nerd Font, close the Font Manager"
        sleep 5
        open -W ./nerd_font.otf

        green_color
        echo "Nerd Font is successfully installed!"
    else
        blue_color
        echo "Skipping Nerd Font installation..."
    fi

    reset_color
    separator
    sleep 1
}

function install_fish() {
    blue_color
    echo "Trying to detect installed Fish Shell..."

    if ! [ $(which fish) ]; then
        blue_color
        echo "Seems like you don't have Fish Shell installed"
        echo "Fish Shell is required to continue the installation"

        green_color
        read -p "Do you agree to install it? (y/N) " -n 1 answer
        echo
        if [ ${answer} != "y" ]; then
            exit 1
        fi

        blue_color
        echo "Installing Fish Shell..."
        echo "The script will ask you the password for sudo 2 times:"
        echo
        echo "1) When adding fish shell into /etc/shells via tee"
        echo "2) When changing your default shell via chsh -s"

        brew install fish
    else
        blue_color
        echo "You already have Fish Shell installed"
        echo "Just to be sure, that this is your default shell, I'm going to call chsh..."
    fi

    echo "$(command -v fish)" | sudo tee -a /etc/shells
    chsh -s "$(command -v fish)"

    green_color
    echo "Fish installed!"

    reset_color
    separator
    sleep 1
}

function install_fisherman() {
    blue_color
    echo "Fisherman is required for the installation"

    green_color
    read -p "Do you agree to install it? (y/N) " -n 1 answer
    echo
    if [ ${answer} != "y" ]; then
        exit 1
    fi

    blue_color
    echo "Installing Fisherman..."

    curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs ${FISHERMAN_URL}

    green_color
    echo "Fisherman installed!"

    reset_color
    separator
    sleep 1
}

function install_fisherman_plugins_and_themes() {
    blue_color
    echo "Some of the Fisherman plugins requires external dependencies to be installed via Homebrew..."

    green_color
    read -p "Do you want to install Themes and Plugins for Fisherman? (y/N) " -n 1 answer
    echo
    if [[ ${answer} == "y" || ${answer} == "Y" ]]; then
        blue_color
        echo "Installing Themes and Plugins..."

        fisher omf/theme-bobthefish

        green_color
        echo "Themes and Plugins installed!"
    else
        blue_color
        echo "Skipping Themes and Plugins installation..."
    fi

    reset_color
    separator
    sleep 1
}

function post_install() {
    green_color
    echo
    echo
    echo "Setup was successfully done"
    echo "Do not forgot to make two simple, but manual things:"
    echo
    echo "1) Open iTerm -> Preferences -> Profiles -> Colors -> Presets and apply color preset"
    echo "2) Open iTerm -> Preferences -> Profiles -> Text -> Font and apply font (for non-ASCII as well)"
    echo
    echo "Happy Coding!"

    reset_color
    exit 0
}


#=============== END - Shell specific stuff ==================#

function on_sigterm() {
    red_color
    echo
    echo -e "Wow... Something serious happened!"
    echo -e "Though, I don't know what really happened :("
    echo -e "Check ghaiklor's repo"

    reset_color
    exit 1
}

hello
install_command_line_tools
install_homebrew
install_git
clone_setup_project
link_config_files
install_apps
set_preferences
install_color_scheme
install_nerd_font
install_fish
install_fisherman
install_fisherman_plugins_and_themes
post_install
