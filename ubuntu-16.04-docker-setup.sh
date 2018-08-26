#!/bin/bash
while true
do
  clear
  echo "=========================="
  echo "Egem Node Installer v1.337"
  echo "=========================="
  echo "Enter 1 to Install Egem Node with Swap File (needed if less than 2GB of RAM available)"
  echo "Enter 2 to Install Egem Node without Swap File"
  echo "Enter q to exit this menu"
  echo -e "\n"
  echo -e "Enter your selection: \c"
  read answer
  case "$answer" in
    1) bash -c "$(wget --no-cache -O - https://raw.githubusercontent.com/buzzkillb/EGEM-node-install/master/createswap.sh)" && bash -c "$(wget --no-cache -O - https://raw.githubusercontent.com/zibastian-mn/docker-masternode-ethergem/master/ubuntu-16.04-docker-deploy.sh)" && exit ;;
    2) bash -c "$(wget --no-cache -O - https://raw.githubusercontent.com/zibastian-mn/docker-masternode-ethergem/master/ubuntu-16.04-docker-deploy.sh)" && exit ;;
    q) exit ;;
  esac
done
