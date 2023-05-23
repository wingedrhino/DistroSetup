#!/bin/sh

printf "Begin Fedora 28 Xfce Spin Setup\n"

printf "\n\nInitial run of dnf update --refresh\n"
dnf update --refresh

printf "\n\nEnable RPM Fusion\n"
dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

printf "\n\nEnable Docker Repo w/ Edge Release\n"
dnf config-manager \
  --add-repo \
  https://download.docker.com/linux/fedora/docker-ce.repo
dnf config-manager --set-enabled docker-ce-edge

printf "\n\nEnable VSCode Repo\n"
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

printf "\n\nRefresh newly added repos via dnf update --refresh\n"
dnf update --refresh

printf "\n\nRemove software we're going to replace\n"
dnf remove \
  midori \
  abiword \
  gnumetric \
  xfce4-clipman-plugin \
  docker \
  docker-common \
  docker-selinux \
  docker-engine-selinux \
  docker-engine \
  transmission \
  geany \
  pragha \
  parole

printf "\n\nInstall Misc CLI Tools\n"
dnf install \
  vim \
  zsh \
  byobu \
  parallel \
  iperf3 \
  nmap \
  iotop \
  htop \
  atop \
  nethogs \
  git-all \
  docker-ce \
  ffmpeg \
  gvfs-mtp \
  simple-mtpfs \
  fuse-exfat \
  gvfs-fuse \
  php \
  ImageMagick

printf "\n\nInstall Misc Graphical Tools\n"
dnf install \
  calibre \
  gimp \
  pinta \
  inkscape \
  libreoffice \
  thunderbird \
  vlc \
  deluge \
  chromium \
  levien-inconsolata-fonts \
  google-roboto-fonts \
  google-roboto-mono-fonts \
  google-roboto-slab-fonts \
  smplayer \
  keepassx \
  parcellite \
  guake \
  VirtualBox \
  mediawriter \
  hexchat \
  cheese \
  xfce4-sensors-plugin \
  redshift-gtk \
  code \
  pcmanfm-qt


printf "\n\nInstall Group: Development Tools (with optional packages)\n"
dnf group install --with-optional "Development Tools"

printf "\n\nInstall Group: C Development Tools And Libraries\n"
dnf group install "C Development Tools and Libraries"

printf "\n\n Install Group: Audio Production (Fedora Jam Packages)\n"
dnf group install "Audio Production"

printf "\n\nFinished setup of Fedora 26 Xfce Spin x86_64!\n\n"
