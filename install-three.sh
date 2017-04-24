#!/bin/sh


function prompt() {
  read -p "$1 (Y/n): "
  case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
    n|no|nope) echo "no" ;;
    *)     echo "yes" ;;
  esac
}

echo "Welcome to the Arch install script, by Saumon, part three :)"
echo "This script MUST be run in the freshly installed Arch system, after booting into it normally."

if [[ $(hostname) = 'archiso' ]]; then
  echo "ERROR: this script must be run on the Arch system, not on the ISO. Please boot normally into the Arch system."
  exit 1
fi
if [ "$EUID" -eq 0 ]; then
  echo "ERROR: this script must be run as your normal (non-root) user that you previously created."
  exit 1
fi

if [[ $(prompt "Start now?") = "no" ]]; then
  echo "Ok :("
  exit 1
fi

username=$(whoami)

gpg --list-keys > /dev/null

echo "Setting up IONIS Wi-Fi connection..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
sudo systemctl stop NetworkManager

echo -n "Please enter your Epitech login: "
read tekuser
echo -n "Please enter your Epitech password: "
read -s tekpass

echo -e "\nCreating IONIS configuration file for NetworkManager..."
cat > IONIS.tmp <<EOF
[connection]
id=IONIS
uuid=38d2646a-994a-4139-a644-bebe756577a9
type=wifi
permissions=user:$username:;
secondaries=

[wifi]
mac-address=E4:B3:18:DB:92:8C
mac-address-blacklist=
mac-address-randomization=0
mode=infrastructure
seen-bssids=
ssid=IONIS

[wifi-security]
auth-alg=open
group=
key-mgmt=wpa-eap
pairwise=
proto=

[802-1x]
altsubject-matches=
eap=peap;
identity=$tekuser
password=$tekpass
phase2-altsubject-matches=
phase2-auth=mschapv2

[ipv4]
dns-search=
method=auto

[ipv6]
addr-gen-mode=stable-privacy
dns-search=
method=auto"
EOF

sudo mv IONIS.tmp /etc/NetworkManager/system-connections/IONIS

sudo systemctl start NetworkManager
echo "Checking Internet connection..."
sleep 4
wget -q --tries=10 --timeout=30 --spider http://google.com
if [[ $? -ne 0 ]]; then
  echo "Error: no Internet connection detected."
  sleep 2
  sudo wifi-menu
  wget -q --tries=10 --timeout=30 --spider http://google.com
  if [[ $? -ne 0 ]]; then
    echo "Error: no Internet connection detected."
    exit 1
  fi
fi

echo "Installing yaourt..."
echo -e "\n\n[archlinuxfr]\n\tSigLevel = Never\n\tServer = http://repo.archlinux.fr/\$arch" | sudo tee -a /etc/pacman.conf > /dev/null
sudo pacman -Syu --noconfirm yaourt
yaourt -Syua --noconfirm
sudo sed '$d' /etc/pacman.conf > /etc/pacman.conf
sudo sed '$d' /etc/pacman.conf > /etc/pacman.conf
sudo sed '$d' /etc/pacman.conf > /etc/pacman.conf
sudo sed '$d' /etc/pacman.conf > /etc/pacman.conf

sudo sed -i '/#TotalDownload/c\TotalDownload' /etc/pacman.conf
sudo sed -i '/#Color/c\Color' /etc/pacman.conf
sudo sed -i '/CheckSpace/c\CheckSpace\nILoveCandy' /etc/pacman.conf

echo "Installing some important packages..."
yaourt -S --noconfirm valgrind clang exfat-utils funny-manpages openssh the_silver_searcher tree unrar youtube-dl python-pip

echo "Installing X graphical server..."
yaourt -S --noconfirm xorg-server xorg-utils xorg-xinit xorg-xrandr xorg-xset xclip xlockmore lxrandr

echo "Installing graphical base..."
yaorut -S --noconfirm lightdm lightdm-gtk-greeter i3

echo "Installing basic graphical tools..."
yaourt -S --noconfirm firefox chromium evince feh ffmpegthumbnailer gnome-calculator gparted libreoffice-still lxrandr maim slop termite thunar thunar-archive-plugin ttf-roboto noto-fonts tumbler vlc

echo "The third and last part is now finished."
echo "Enjoy :)"

exit 0
