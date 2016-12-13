# Scrapy Vagrant blueprint on Centos 7

## Workflow

Start the VM. The Vagrant's `shell` provisioning appends the host's public ssh key to the VM `authorized_keys`. Execute from: `local@host_machine`

```
vagrant up
```

Map on your/host `hosts` file the IP of the guest VM. Edit the `C:\Windows\System32\drivers\etc\hosts` and add:

```
# Vagrant
192.168.33.100 scrapy.dev
```

Run the `after-boot-script.sh` script

```
./after-boot-script.sh
```

Login

```
# Login over the normal SSH using the keys we just applied
ssh vagrant@scrapy.dev

# Or login using Vagrant SSH
vagrant ssh
```

Run the ansible provisioning inside the VM

```
cd /home/vagrant/ansible-playbook-scrapy/
# Run the fisrt playbook in order to download the ansible roles
ansible-playbook -i hosts playbook_ansible.yml
# Run the actual playbook that will apply the configuration and set up scrapy
ansible-playbook -i hosts playbook_scrapy.yml
```
