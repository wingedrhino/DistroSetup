#!/bin/sh

echo "Begin Fedora Workstation x86_64 Setup"
echo "This adds x86_64 specific packages to Fedora Workstation"

echo "Enable Brave Repos"
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc 

echo "Install New Software"
sudo dnf install \
  pycharm-community \
  pycharm-community-doc \
  pycharm-community-plugins \
  nautilus-image-converter \
  bino \
  brave-browser;


echo "Done!"

