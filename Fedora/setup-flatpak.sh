#!/bin/sh
echo "Begin Fedora Workstation Flatpak Setup"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub \
  org.telegram.desktop \
  org.signal.Signal \
  com.redis.RedisInsight \
  io.dbeaver.DBeaverCommunity \
  org.videolan.VLC \
  org.bino3d.bino \
  fr.handbrake.ghb\
  com.obsproject.Studio \
  org.kde.kdenlive \
  org.shotcut.Shotcut
echo "Finished Fedora Workstation Flatpak Setup"

