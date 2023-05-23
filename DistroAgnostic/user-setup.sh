#!/bin/sh

echo "Preparing system for user $USER"
echo "Run this command for all users (including root)!"

echo "Setup Byobu\n"
byobu-ctrl-a screen
echo "Install ~/.zshrc"
cp ../dotfiles/zshrc ~/.zshrc
echo "Install ~/.profile"
cp ../dotfiles/profile ~/.profile
echo "Install ~/.vimrc"
cp ../dotfiles/vimrc ~/.vimrc
echo "Install ~/.gitconfig"
cp ../dotfiles/gitconfig ~/.gitconfig

echo "Create essential directories"
mkdir -p $HOME/Documents/workspace $HOME/Documents/vault $HOME/Documents/appdata $HOME/bin $HOME/go

echo "Change shell from $SHELL to zsh"
chsh -s /usr/bin/zsh

echo "Add user to various groups"
sudo gpasswd -a $USER vboxusers
sudo gpasswd -a $USER audio
sudo gpasswd -a $USER realtime
sudo gpasswd -a $USER docker
sudo gpasswd -a $USER uucp
sudo gpasswd -a $USER adbusers
sudo gpasswd -a $USER bumblebee

echo "Enable bumblebee if installed, for nvidia power management"
sudo systemctl enable bumblebee
