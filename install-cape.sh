#!/bin/bash

echo "=================================================="
echo -e "\033[0;35m"
echo "                             .__      ";
echo "   _________.__. ____ _____  |  |__   ";
echo "  / ____<   |  |/ __ \\__  \ |  |  \  ";
echo " < <_|  |\___  \  ___/ / __ \|   Y  \ ";
echo "  \__   |/ ____|\___  >____  /___|  / ";
echo "     |__|\/         \/     \/     \/  ";
echo "                                      ";
echo -e "\e[0m"
echo "=================================================="

sleep 1

echo -e "\e[1m\e[32m1. Set RDP User Parameter \e[0m" && sleep 1

echo -e "\e[1m\e[32m1.1 Set Username \e[0m" && sleep 1

while :
do
  read -p "INPUT RDP Username: " RDPUSERNAME
  if [ -n "$RDPUSERNAME" ]; then
    break
  fi
done

echo -e "\e[1m\e[32m1.2 Set your RDP Password \e[0m" && sleep 1

while :
do
  read -p "INPUT RDP Password: " RDPPASSWORD
  if [ -n "$RDPPASSWORD" ]; then
    break
  fi
done

echo "=================================================="
echo -e "\e[1m\e[32m2. Install prerequisites\e[0m" && sleep 1

cd $HOME
sudo apt update -y
sudo apt upgrade -y
sudo apt install docker-compose
sudo apt install -y ubuntu-desktop
sudo apt install -y xrdp
curl https://www.espressosys.com/cape/docker-compose.yaml --output docker-compose.yaml

echo "=================================================="
echo -e "\e[1m\e[32m3. Add RDP User\e[0m" && sleep 1
adduser $RDPUSERNAME --disabled-password --gecos ""
echo $RDPUSERNAME:$RDPPASSWORD | /usr/sbin/chpasswd

gpasswd -a $RDPUSERNAME sudo

echo "=================================================="
echo -e "\e[1m\e[32m4. Set up RDP config\e[0m" && sleep 1

sed -e 's/^new_cursors=true/new_cursors=false/g' -i /etc/xrdp/xrdp.ini

systemctl restart xrdp
systemctl enable xrdp.service
systemctl enable xrdp-sesman.service

su - $RDPUSERNAME

cd ~
DESKTOP=/usr/share/ubuntu:/usr/local/share:/usr/share:/var/lib/snapd/desktop

cat <<EOF > ~/.xsessionrc
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_DATA_DIRS=${DESKTOP}
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
EOF


echo $RDPUSERNAME | sudo -S cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/xrdp-color-manager.pkla
[Netowrkmanager]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

echo "=================================================="
echo -e "\e[1m\e[32m5. Restart RDP process\e[0m" && sleep 1
sudo systemctl restart polkit

echo "=================================================="
echo -e "\e[1m\e[32m6. Install Google Chrome\e[0m" && sleep 1

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

sudo apt install ./google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb

echo "=================================================="
echo -e "\e[1m\e[32m7. Launch Cape\e[0m" && sleep 1

exit
docker-compose up

echo "=================================================="
