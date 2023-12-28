STORAGE_1=/dev/sda
STORAGE_2=/dev/sdb
# Create the setup for the first time
sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 $STORAGE_1 $STORAGE_2
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

