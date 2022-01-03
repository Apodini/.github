export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade


# Setup Swap based of https://bogdancornianu.com/change-swap-size-in-ubuntu/

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
sudo swapon --show


# Install Docker

sudo DEBIAN_FRONTEND=noninteractive apt-get -y install linux-modules-extra-raspi ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo DEBIAN_FRONTEND=noninteractive gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install docker-ce docker-ce-cli containerd.io

sudo groupadd docker
sudo usermod -aG docker $USER
docker --version

sudo systemctl enable docker.service
sudo systemctl enable containerd.service


# Schedule Restart and Clean Every Day

sudo crontab -l > restartandclean
echo "0 4 * * * shutdown -r now" >> restartandclean
echo "0 4 * * * rm -rf /home/ubuntu/actions-runner/_work" >> restartandclean
crontab restartandclean
rm restartandclean


# Reboot

sudo systemctl reboot