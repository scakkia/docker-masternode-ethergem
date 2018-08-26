#!/bin/bash
#
# https://github.com/zibastian-mn/docker-masternode-ethergem


#################
# System checks #
#################

system_Checks () {
	clear
	echo "Getting System informations... Please wait"

	MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')
	CPUs=$(grep -c ^processor /proc/cpuinfo)
	OS=$(lsb_release -a 2>&1 | grep 'Distributor ID' | awk '{print $3}')
	VERSION=$(lsb_release -a 2>&1 | grep 'Release' | awk '{print $2}')

	if [ -x "/usr/bin/docker" ] || [ -x "/usr/local/bin/docker" ]; then
		DOCKER='Installed'
	else
		DOCKER='Need to be installed'
	fi
}




####################
# Custom variables #
####################

cRed='\e[31m'
cNone='\e[0m'
cYellow='\e[93m'
SKIP_SWAP=0



#############
# Functions #
#############

fHeaders () {
	clear
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
                     Node installer'
    echo ""
	echo -e "  ${cYellow}OS     : ${cNone}${OS} ${VERSION}"
	echo -e "  ${cYellow}Memory : ${cNone}${MEMORY} KB"
	echo -e "  ${cYellow}CPU(s) : ${cNone}${CPUs}"
	echo ""
	echo -e "  ${cYellow}Docker : ${cNone}${DOCKER}"
	echo ""
}

check_Memory () {
	SWAP=$(grep swapfile /proc/swaps | awk '{print $1}')

	if [ $MEMORY -gt 2000000 ]; then
		req_MEMORY=1
	else
		if [ -z "$SWAP" ]; then
			req_MEMORY=0
		else
			req_MEMORY=1
		fi
	fi

	if [ $req_MEMORY -eq 0 ]; then
		echo -e "  ${cRed}Warning ! ${cNone}Your system has less than 2 GB of RAM and swapfile is missing."
		echo "  This may lead to system crashes and lost rewards."
		echo ""
		echo "  We recommend to create a swapfile. Do you want to create one ?"
		echo -n "  Enter 'Yes' or 'No' : "
		read answer
		case "$answer" in
			"Yes" | "YES" | "yes")
				create_Swap
				SKIP_SWAP=0
				;;
			"No" | "NO" | "no")
				SKIP_SWAP=1
				;;
			*)
				fHeaders
				check_Memory
				;;
		esac
	fi
}

create_Swap () {
	clear
	sudo fallocate -l 2G /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
	fHeaders
	check_Memory
}

install_Docker () {
	clear
	echo "The setup of Docker will start in 5 seconds"
	sleep 5
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

	sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"

	sudo apt-get update && apt-get install docker-ce -y

	sudo systemctl enable docker
	sudo systemctl start docker
}

get_instance_Name () {
	echo ""
	echo "  How would you like to name your node ? (Example: TeamEGEM Node West Coast Europe) "
	echo -n "  Node's name : "
	read INSTANCE_NAME
	case "$INSTANCE_NAME" in
		"")
			fHeaders
			get_instance_Name
			;;
		*)
			;;
	esac
}

get_instance_Contact () {
	echo -n "  Node's contact : "
	read CONTACT_DETAILS
	case "$CONTACT_DETAILS" in
		"")
			get_instance_Contact
			;;
		*)
			;;
	esac
}


#########
# Start #
#########

system_Checks
fHeaders

if [ "$OS" != "Ubuntu" ] || [ "$VERSION" != "16.04" ]; then
	echo "  Sorry, this installer only supports Ubuntu 16.04 currently."
	echo "  You can try to install docker and launch a container manually."
	echo ""
	echo "  More info at https://hub.docker.com/r/zibastian/masternode-ethergem/"
	echo ""
	exit
fi

if [ $SKIP_SWAP -eq 0 ]; then
	check_Memory
fi



############################
# Getting instance details #
############################

get_instance_Name
echo ""
echo "  What is your node's contact details ? (Example: Twitter:@TeamEGEM) "
get_instance_Contact



##################
# System upgrade #
##################

clear
echo "The system update will start in 10 seconds"
echo -e "${cYellow}If prompted about Grub Configuration select keep the local version currently installed${cNone}"
sleep 10

sudo apt-get update && apt-get upgrade -y

783895880cab96ec78db50b3cb34b53bc4a024d17309b8123229c69882e61cca

#######################
# System dependencies #
#######################

clear
echo "The system dependencies setup will start in 5 seconds"
sleep 5

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



################
# Docker setup #
################

if [ "$DOCKER" == "Need to be installed" ]; then
	install_Docker
fi

system_Checks
fHeaders



#####################
# Starting the node #
#####################

echo "  Setup done. Starting the node"
echo ""
CONTAINER=$(
	docker run -d --restart=unless-stopped \
               -v egem-node:/opt/egem -p 30666:30666 \
               -e conf_NAME="${INSTANCE_NAME}" -e conf_CONTACT="${CONTACT_DETAILS}" \
               zibastian/masternode-ethergem | grep -E '^\w{64}$'
)

if [ ! -z "$CONTAINER" ]; then
	NAME=$(docker inspect --format='{{.Name}}' $CONTAINER | sed -e 's/^\///g')
	fHeaders
	echo -e "  All good ! Your node is running under a docker container named ${cYellow}${NAME}${cNone}"
	echo "  Your node should be listed on https://network.egem.io in few seconds"
	echo ""
	echo "  Use 'docker ps' to get more details"
	echo ""
else
	echo -e "  ${cRed}Error ! ${cNone}Docker instance not found. Please check the system logs :-("
fi
