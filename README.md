Introduction
---
This image is running an EGEM Quarry Masternode on the lightweight Alpine Linux distribution.

**GitHub:** https://github.com/zibastian-mn/docker-masternode-ethergem/ 
**Docker:** https://hub.docker.com/r/zibastian/masternode-ethergem/

---
Starting a node
---
```sh
docker run -d --restart=unless-stopped --name <CONTAINER_NAME> \
               -v egem-node:/opt/egem -p 30666:30666 \
               -e conf_NAME="<NODE NAME>" -e conf_CONTACT='Discord:@...' \
               zibastian/masternode-ethergem
```

---
**Do not forget to replace <CONTAINER_NAME>, <NODE NAME> and your contact details.**  
Go to https://network.egem.io/ and wait for your node to pop up into the stats.  

---
Uninstall
---
```sh
docker rm -f <CONTAINER_NAME> && docker volume rm egem-node
```
---
Container logs
---
```bash
docker logs -f <CONTAINER_NAME> [--tail 20]
```

---
Node.js app status
---
```bash
docker exec -ti <CONTAINER_NAME> pm2 show node-app
```

---
Node.js app logs
---
```bash
docker exec -ti <CONTAINER_NAME> pm2 logs node-app [--lines 1000]
```

---
Donation
---
If this image helps you reduce time to deploy, I like beer :)

**EGEM:** 0x720752E61664a1B81B2ec9F7E709D0bCDB55502f  
**ETH:** 0x13B0E1c351e4a9Eae4980ae5469022808C8B3B6D  
**LTC:** MBiWJ3HB69nXtfxvdFmZE5iGm5AXWPRZuh  
**BTC:** 3NshfttcuYKNrU8CCwFqzuu8x95VtGQeu4  
