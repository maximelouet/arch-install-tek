#!/bin/sh


function prompt() {
  read -p "$1 (Y/n): "
  case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
    n|no|nope) echo "no" ;;
    *)     echo "yes" ;;
  esac
}

echo "Welcome to the Arch install script, by Saumon, part two :)"
echo "This script MUST be run in the freshly installed Arch system, from the ISO image, via arch-chroot."

if [[ $(prompt "Start now?") = "no" ]]; then
  echo "Ok :("
  exit 1
fi

echo "Setting languages..."
sed -i '/#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8' /etc/locale.gen
sed -i '/#fr_FR.UTF-8 UTF-8/c\fr_FR.UTF-8 UTF-8' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr-latin1" > /etc/vconsole.conf

echo "Please choose your hostname :) (no spaces allowed)"
echo -n "Hostname: "
read hostname
echo $hostname > /etc/hostname
sed '$d' /etc/hosts > /etc/hosts
sed '$d' /etc/hosts > /etc/hosts
echo "127.0.0.1\t$hostname.localdomain\t$hostname" >> /etc/hosts
echo '# End of file' >> /etc/hosts

echo "Please choose your Linux user name :) (no spaces allowed)"
echo -n "Username: "
read username
useradd -m $username
echo "Please set a password for the '$username' user:"
passwd $username

echo "Giving the '$username' user sudo permissions..."
echo "$username ALL=(ALL) ALL" >> /etc/sudoers
echo "Defaults insults" >> /etc/sudoers

echo "Please also set a password for the 'root' user:"
passwd root

echo "Initializing some databases..."
pacman-key --init
pacman-key --populate archlinux
gpg --list-keys > /dev/null

echo "The second part is now finished."
echo "Please update the Blinux bootloader in order to boot into your new Arch system, and then run the third (and last) script with the command 'saumon-three'"

exit 0
