# Scrapy Vagrant blueprint on Centos 7

### Workflow

Start the VMs. The Vagrant's `shell` provisioning appends the host's public ssh key to all VM `authorized_keys`.
Execute from: `local@host_machine`

    vagrant up

Map on your/host `hosts` file the IP and the guest VM. Edit the `C:\Windows\System32\drivers\etc\hosts` and add:

    # Vagrant
    192.168.33.100 scrapy.dev

Run the `after-boot-script.sh` script

    ./after-boot-script.sh
