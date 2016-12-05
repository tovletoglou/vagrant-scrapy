#!/bin/bash

# ==============================================================================
# Backup

HOSTS_FILE="C:\Windows\System32\drivers\etc\hosts"

if [ ! -d ./tmp ]; then
  echo -e "\n\033[0;36mCreate tmp directory\033[0m"
  mkdir ./tmp
fi

echo -e "\n\033[0;36mBackup host's known_hosts\033[0m"
cp ~/.ssh/known_hosts ./tmp/backup-known_hosts

echo -e "\n\033[0;36mBackup host's hosts file\033[0m"
cp "$HOSTS_FILE" ./tmp/backup-hosts

# ==============================================================================
# Update host's hosts file (need to run as root/administrator).

echo -e "\n\033[0;36mUpdate host's hosts file (need to run as root/administrator).\033[0m"

HOSTS_FILE="C:\Windows\System32\drivers\etc\hosts"

HOSTS_ENTRIES_ARRAY[0]='192.168.33.100 scrapy.dev'

for i in "${HOSTS_ENTRIES_ARRAY[@]}"
do
  if grep -q "$i" "$HOSTS_FILE"; then
    echo "Host entry '$i' found on $HOSTS_FILE"
  else
    echo "Updating $HOSTS_FILE. Adding: $i"
    echo "$i" >> "$HOSTS_FILE"
  fi
done

# ==============================================================================
# Add on host's known_hosts the public key of the guest VMs.

echo -e "\n\033[0;36mAdd on host's known_hosts the public key of the guest VMs.\033[0m"

KNOWN_HOSTS_ENTRIES_ARRAY[0]='scrapy.dev,192.168.33.100'

for i in "${KNOWN_HOSTS_ENTRIES_ARRAY[@]}"
do
  if grep -q "$i" ~/.ssh/known_hosts; then
    echo "Host entry '$i' found on ~/.ssh/known_hosts"
  else
    echo "Updating ~/.ssh/known_hosts. Adding: $i"

    ssh-keyscan -t rsa $i 2>&1 | \grep -v '#' | sort -u - ~/.ssh/known_hosts > ~/.ssh/tmp_known_hosts
    mv ~/.ssh/tmp_known_hosts ~/.ssh/known_hosts
  fi
done

# ==============================================================================
# Copy the scrapy.dev public key to the host, in order to push it on the clients.

echo -e "\n\033[0;36mCopy the scrapy.dev public key to the host, in order to push it on the clients.\033[0m"
scp vagrant@scrapy.dev:/home/vagrant/.ssh/id_rsa.pub ./tmp/scrapy_server_id_rsa.pub

# ==============================================================================
# Add the scrapy.dev public key on the known_hosts of clients.

echo -e "\n\033[0;36mAdd the scrapy.dev public key on the known_hosts of clients.\033[0m"

ssh vagrant@scrapy.dev "cat >> /home/vagrant/.ssh/authorized_keys" < ./tmp/scrapy_server_id_rsa.pub
