#!/bin/sh

ROOT=/dev/sda9
HOME=/dev/sda10
MOUNT=/mnt

function prompt() {
  read -p "$1 (Y/n): "
  case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
    n|no|nope) echo "no" ;;
    *)     echo "yes" ;;
  esac
}

echo "Welcome to the Arch install script, by Saumon :)"
echo "IMPORTANT: this script will NOT work if you changed partitions before /dev/sda8"

loadkeys fr

echo -ne "\nPlease enter your Epitech login: "
read tekuser
echo -n "Please enter your Epitech password: "
read -s tekpass

echo -e "\nCreating IONIS configuration file for netctl..."
cat > IONIS.tmp <<EOF
Description='IONIS Network configuration'
Interface=wlp2s0
Connection=wireless
Security=wpa-configsection
ESSID=IONIS
IP=dhcp
WPAConfigSection=(
	'ssid="IONIS"'
	'key_mgmt=WPA-EAP'
	'eap=PEAP'
	'proto=RSN'
	'pairwise=CCMP'
	'auth_alg=OPEN'
	'identity="$tekuser"'
	'password="$tekpass"'
	'phase1="peaplabel=auto peapver=0"'
	'phase2="auth=MSCHAPV2"'
)
EOF

mv IONIS.tmp /etc/netctl/IONIS

echo -e "\nPlease select 'IONIS' in the list after pressing enter"

sleep 2
wifi-menu

echo "Checking Internet connection..."
wget -q --tries=5 --timeout=10 --spider http://google.com
if [[ $? -ne 0 ]]; then
  echo "Error: no Internet connection detected. Please setup a Hotspot and connect to it using wifi-menu"
  exit 1
fi

echo -e "Nice! :)\n"

timedatectl set-ntp true

echo -ne "\nFormat partitions now?"
if [[ $(prompt "") == "no" ]]; then
  echo "User cancelled operation."
  exit 1
fi

echo "Formatting partitions..."
mkfs.ext4 $ROOT
mkfs.ext4 $HOME
mkswap /dev/sda5

echo "Mounting partitions..."
mount $ROOT $MOUNT
mkdir -p $MOUNT/home
mount $HOME $MOUNT/home
swapon /dev/sda5

echo "Installing base system..."
pacstrap $MOUNT base base-devel

echo "Installing some needed packages..."
pacstrap $MOUNT vim git wget alsa-utils wpa_supplicant dialog networkmanager network-manager-applet

echo "Generating fstab..."
genfstab -U -p $MOUNT >> $MOUNT/etc/fstab

cat $MOUNT/etc/fstab
echo -e "\nIs this fstab correct ? If you answer 'no', it will be opened with vim."
if [[ $(prompt "") == "no" ]]; then
  vim $MOUNT/etc/fstab
fi

echo "The first part is now finished."
echo "Please run the second part of the script with the command 'saumon-two'."

arch-chroot $MOUNT
