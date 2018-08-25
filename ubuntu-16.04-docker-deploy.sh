
#!/bin/bash

echo '
      ___           ___           ___           ___     
     /\__\         /\__\         /\__\         /\  \    
    /:/ _/_       /:/ _/_       /:/ _/_       |::\  \   
   /:/ /\__\     /:/ /\  \     /:/ /\__\      |:|:\  \  
  /:/ /:/ _/_   /:/ /::\  \   /:/ /:/ _/_   __|:|\:\  \ 
 /:/_/:/ /\__\ /:/__\/\:\__\ /:/_/:/ /\__\ /::::|_\:\__\
 \:\/:/ /:/  / \:\  \ /:/  / \:\/:/ /:/  / \:\~~\  \/__/
  \::/_/:/  /   \:\  /:/  /   \::/_/:/  /   \:\  \      
   \:\/:/  /     \:\/:/  /     \:\/:/  /     \:\  \     
    \::/  /       \::/  /       \::/  /       \:\__\    
     \/__/         \/__/         \/__/         \/__/    
      ___           ___                         ___     
     /\  \         /\  \         _____         /\__\    
     \:\  \       /::\  \       /::\  \       /:/ _/_   
      \:\  \     /:/\:\  \     /:/\:\  \     /:/ /\__\  
  _____\:\  \   /:/  \:\  \   /:/  \:\__\   /:/ /:/ _/_ 
 /::::::::\__\ /:/__/ \:\__\ /:/__/ \:|__| /:/_/:/ /\__\
 \:\~~\~~\/__/ \:\  \ /:/  / \:\  \ /:/  / \:\/:/ /:/  /
  \:\  \        \:\  /:/  /   \:\  /:/  /   \::/_/:/  / 
   \:\  \        \:\/:/  /     \:\/:/  /     \:\/:/  /  
    \:\__\        \::/  /       \::/  /       \::/  /   
     \/__/         \/__/         \/__/         \/__/    


'
echo -n "How would you like to name your instance? (Example: TeamEGEM Node West Coast Europe) "
read INSTANCE_NAME
name=$(echo $INSTANCE_NAME)

echo -n "What is your node's contact details? (Example: Twitter:@TeamEGEM) "
read CONTACT_DETAILS
details=$(echo $CONTACT_DETAILS)

echo ""
echo ""
echo "Updating linux packages"
echo "If prompted about Grub Configuration select keep the local version currently installed"
sleep 10

sudo apt-get update && apt-get upgrade -y

sudo  apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl software-properties-common fail2ban ufw

ufw default allow outgoing
ufw default deny incoming
ufw allow ssh/tcp
ufw limit ssh/tcp
ufw allow 8545/tcp
ufw allow 30666/tcp
ufw allow 30661/tcp
ufw logging on
ufw --force enable

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
  
sudo apt-get update && apt-get install docker-ce -y

sudo systemctl enable docker
sudo systemctl start docker

docker run -d --restart=unless-stopped \
               -v egem-node:/opt -p 30666:30666 \
               -e conf_NAME="${name}" -e conf_CONTACT="${details}" \
               zibastian/egem-quarry-node
               
echo ""
echo "all done"
echo ""
docker ps

              
