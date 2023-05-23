#!/bin/sh

echo "Begin Fedora Workstation Setup"
echo "This sets up the machine for use as a headless development server"

if ! grep -qe "fastestmirror=1" "/etc/dnf/dnf.conf"; then
  echo "Add fastestmirror=1 to /etc/dnf/dnf.conf"
  sudo su -c "echo 'fastestmirror=1' >> /etc/dnf/dnf.conf"
fi

if ! grep -qe "keepcache=1" "/etc/dnf/dnf.conf"; then
  echo "Add keepcache=1 to /etc/dnf/dnf.conf"
  sudo su -c "echo 'keepcache=1' >> /etc/dnf/dnf.conf"
fi


echo "Enable RPM Fusion Repos"
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "Enable Brave Repos"
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc 

echo "Enable VS Code Repos"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

echo "Install New Software"
sudo dnf install \
  NetworkManager-tui \
  protonvpn-cli \
  util-linux-user \
  fail2ban \
  mosh \
  snapd \
  vim \
  zsh \
  byobu \
  levien-inconsolata-fonts \
  parallel \
  rclone \
  iperf3 \
  nmap \
  iotop \
  htop \
  atop \
  nethogs \
  ntpstat \
  ntpsec \
  ntpcheck \
  gnupg \
  sshfs \
  gvfs-mtp \
  simple-mtpfs \
  fuse-exfat \
  gvfs-fuse \
  git-all \
  nginx \
  bind \
  traceroute \
  moby-engine \
  moby-engine-zsh-completion \
  docker-compose \
  kernel-headers \
  "@C Development Tools and Libraries" \
  "@Development Tools" \
  "@Python Classroom" \
  "@Python Science" \
  rust \
  cargo \
  nodejs \
  yarnpkg \
  java-11-openjdk \
  java-11-openjdk-devel \
  java-latest-openjdk \
  java-latest-openjdk-devel \
  go \
  php \
  composer \
  vala \
  vala-doc \
  "@Security Lab" \
  nautilus-dropbox \
  nautilus-image-converter \
  nautilus-extensions \
  nautilus-gsconnect \
  gnome-shell-extension-gsconnect \
  gnome-shell-extension-dash-to-dock \
  telegram-desktop \
  hexchat \
  deluge \
  chromium \
  gparted \
  gnome-disk-utility \
  keepassxc \
  brave-browser \
  code \
  meld \
  vlc \
  smplayer \
  xine-ui \
  bino \
  ffmpeg \
  mencoder \
  ImageMagick \
  akmod-v4l2loopback \
  obs-studio \
  HandBrake-gui \
  olive \
  kdenlive \
  shotcut \
  gimp \
  inkscape \
  blender \
  krita \
  darktable \
  "@Audio Production" \
  libreoffice \
  calibre \
  "@Authoring and Publishing" \
  google-roboto-fonts \
  google-roboto-mono-fonts \
  google-roboto-slab-fonts \
  comic-neue-fonts \
  comic-neue-angular-fonts \
  --setopt=group_package_types="mandatory,default,optional"

echo "Run dnf Autoremove"
sudo dnf autoremove

echo "Enable & Start Services"
sudo systemctl enable --now sshd
sudo systemclt enable --now docker
echo "Add User to New Groups"
sudo usermod -aG audio $USER
sudo usermod -aG docker $USER
