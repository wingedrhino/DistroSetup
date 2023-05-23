#!/bin/sh

echo "Begin Fedora Workstation x86_64 Setup"
echo "This adds x86_64 specific packages to Fedora Workstation"

echo "Enable Brave Repos"
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc 


echo "Install New Software"
sudo dnf install brave-browser;


echo "Enable FlatHub Repo"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Install Redis Desktop Manager via Flatpak"
sudo flatpak install flathub app.resp.RESP

echo "Install Signal via FlatHub"
sudo flatpak install flathub org.signal.Signal

echo "Final System Updates - these are NOT unattended!"
sudo flatpak update

echo "Done!"

