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

echo "Enable PostgreSQL 14 Repos"
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-35-x86_64/pgdg-fedora-repo-latest.noarch.rpm
sudo dnf install -y https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-fedora-repo-2-1.noarch.rpm

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
  yarnpkg \
  java-11-openjdk \
  java-11-openjdk-devel \
  java-latest-openjdk \
  java-latest-openjdk-devel \
  go \
  nodejs \
  php \
  composer \
  postgresql14-server \
  pgadmin4 \
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
  electrum \
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

echo "Setting up MongoDB Compass"
if ! which mongodb-compass; then
  echo "Installing MongoDB Compass"
  sudo dnf install https://downloads.mongodb.com/compass/mongodb-compass-1.26.1.x86_64.rpm
fi

echo "Setting up Insomnia REST"
if ! which insomnia; then
  echo "Installing Insomnia REST"
  sudo dnf install https://github.com/Kong/insomnia/releases/download/core%402021.6.0/Insomnia.Core-2021.6.0.rpm
fi

# echo "Install Node.js 17.x"
# sudo dnf module install nodejs:17/default

echo "Enable Snap Classic"
sudo ln -s /var/lib/snapd/snap /snap

echo "Install Heroku CLI via Snap"
sudo snap install heroku --classic

echo "Install Redis Desktop Manager via Snap"
sudo snap install redis-desktop-manager

echo "Enable FlatHub Repo"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Install Signal Messenger via FlatHub"
flatpak install flathub org.signal.Signal

echo "Enable & Start Services"
sudo systemctl enable --now sshd
sudo systemclt enable --now docker
echo "Add User to New Groups"
sudo usermod -aG audio $USER
sudo usermod -aG docker $USER

