#!/bin/sh

ROOT=/dev/sda9
HOME=/dev/sda10


function prompt() {
  read -p "$1 (Y/n): "
  case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
    n|no|nope) echo "no" ;;
    *)     echo "yes" ;;
  esac
}

echo "Welcome to the Arch install script, by Saumon :)"
echo "IMPORTANT: this script will NOT work if you changed partitions before /dev/sda8"

echo "Checking Internet connection..."
wget -q --tries=5 --timeout=10 --spider http://google.com
if [[ $? -ne 0 ]]; then
  echo "Error: no Internet connection detected. Please setup a Hotspot and connect to it using wifi-menu"
  exit 1
fi

loadkeys fr

timedatectl set-ntp true

echo "Formatting partitions..."
mkfs.ext4 $ROOT
mkfs.ext4 $HOME
mkswap /dev/sda5

echo "Mounting partitions..."
mount $ROOT /mnt
mkdir -p /mnt/home
mount $HOME /mnt/home
swapon /dev/sda5

echo "Installing base system..."
pacstrap /mnt base base-devel

echo "Installing some needed packages..."
pacstrap /mnt vim git alsa-utils wpa_supplicant dialog networkmanager network-manager-applet

echo "Generating fstab..."
genfstab -U -p /mnt >> /mnt/etc/fstab

cat /mnt/etc/fstab
echo -e "\nIs this fstab correct ? If you answer 'no', it will be opened with vim."
if [[ $(prompt "") == "no" ]]; then
  vim /mnt/etc/fstab
fi

echo "The first part is now finished."
echo "Please run the second part of the script with the command 'saumon-two'."

arch-chroot /mnt
