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
  neovim \
  zsh \
  byobu \
  levien-inconsolata-fonts \
  parallel \
  smartmontools \
  rclone \
  s3cmd \
  iperf3 \
  tilix \
  tilix-nautilus \
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
  android-tools \
  rpi-imager \
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
  pipx \
  python3-mypy \
  python3-mypy_extensions \
  pycharm-community \
  pycharm-community-doc \
  pycharm-community-plugins \
  rust \
  cargo \
  perl \
  java-11-openjdk \
  java-11-openjdk-devel \
  java-latest-openjdk \
  java-latest-openjdk-devel \
  go \
  php \
  composer \
  redis \
  pgadmin4 \
  pgcli \
  vala \
  vala-doc \
  "@Security Lab" \
  gnome-tweaks \
  nautilus-dropbox \
  nautilus-image-converter \
  nautilus-extensions \
  nautilus-gsconnect \
  gnome-shell-extension-gsconnect \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-auto-move-windows \
  gnome-shell-extension-caffeine \
  gnome-shell-extension-freon \
  gnome-shell-extension-gpaste \
  gnome-shell-extension-netspeed \
  gnome-shell-extension-sound-output-device-chooser \
  gnome-shell-extension-system-monitor-applet \
  gnome-shell-extension-workspace-indicator \
  hexchat \
  deluge \
  gparted \
  gnome-disk-utility \
  keepassxc \
  electrum \
  firefox \
  brave-browser \
  code \
  neovim-qt \
  meld \
  vlc \
  smplayer \
  gthumb \
  bino \
  ffmpeg \
  mencoder \
  ImageMagick \
  akmod-v4l2loopback \
  stellarium \
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
  helvum \
  easyeffects \
  lv2-setBfree-plugins \
  lv2-calf-plugins-gui \
  lv2-guitarix-plugins \
  lv2-drumkv1 \
  lv2-fabla \
  lv2-x42-plugins \
  lv2-samplv1 \
  lv2-mdala-plugins \
  lv2-mdaEPiano \
  lv2-zynadd-plugins \
  lv2-vocoder-plugins \
  lv2-sorcer \
  lv2-amsynth-plugin \
  Carla \
  hydrogen \
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
  sudo dnf install https://downloads.mongodb.com/compass/mongodb-compass-1.32.6.x86_64.rpm
fi

echo "Install PostgreSQL 14.x"
sudo dnf module install postgresql:14/server

echo "Enable Snap Classic"
sudo ln -s /var/lib/snapd/snap /snap

echo "Install Heroku CLI via Snap"
sudo snap install heroku --classic

echo "Install Node.js via Snap"
sudo snap install node --classic --channel=18

echo "Install Redis Desktop Manager via Snap"
sudo snap install redis-desktop-manager

echo "Enable FlatHub Repo"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Install Signal via FlatHub"
sudo flatpak install flathub org.signal.Signal

echo "Enable & Start Services"
sudo systemctl enable --now sshd
sudo systemctl enable --now docker

echo "Add User to New Groups"
sudo usermod -aG audio $USER
sudo usermod -aG docker $USER

echo "Final System Updates - these are NOT unattended!"
sudo snap refresh
sudo flatpak update
sudo dnf update

echo "Done!"

