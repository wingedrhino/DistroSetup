sudo cp *.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
