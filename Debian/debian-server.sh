echo "Setting up Debian Server"

echo "Initial update and upgrade"
sudo apt update
sudo apt full-upgrade

echo "Install essential headless software"
sudo apt install \
  git \
  build-essential \
  fail2ban \
  mosh \
  byobu \
  zsh \
  vim \
  neovim \
  cryptsetup \
  smartmontools \
  htop \
  iotop \
  mdadm \
  s3cmd \
  s4cmd

