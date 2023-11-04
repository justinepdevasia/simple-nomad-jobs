#!/bin/bash

# Install necessary packages
sudo apt install zsh fd-find -y

# Switch to zsh
zsh

# Install oh-my-zsh with automatic "Y" response
echo -e '\n' | sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/agkozak/zsh-z ~/.oh-my-zsh/custom/plugins/zsh-z

# Clone and install FZF with automatic "Y" response
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
echo -e '\n' | ~/.fzf/install

# Change the default shell to zsh for the user 'openvscode-server'
sudo chsh -s "$(which zsh)" openvscode-server

# Source the updated .zshrc
source ~/.zshrc

# Provide a message indicating the script has finished
echo "Setup completed. You are now using zsh as your default shell."
