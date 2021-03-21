#!/usr/bin/env bash
set -e
trap on_sigterm SIGKILL SIGTERM

function link_config_files() {
  echo "Linking config files?"

  read -p "Do you want to link the config files? (y/N) " -n 1 answer
  echo
  if [ ${answer} != "y" ]; then
      echo "Skipping config file linking..."
  else
    ln -s -f ~/.dotfiles/.Brewfile ~/.Brewfile
    ln -s -f ~/.dotfiles/.gitconfig ~/.gitconfig
    ln -s -f ~/.dotfiles/.ssh/config ~/.ssh/config
    mkdir -p ~/.unison
    ln -s -f ~/.dotfiles/.unison ~/.unison

    echo "Config files (symbolically) linked!"
  fi

  sleep 1
}

function on_sigterm() {
    echo
    echo -e "Wow... Something serious happened!"
    exit 1
}

link_config_files
