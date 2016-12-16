# -*- mode: ruby -*-
# vi: set ft=ruby :

# ------------------------------------------------------------------------------
# Custom variables (edit these values)
# ------------------------------------------------------------------------------

# Define the VM's hostname.
SCRAPY_HOSTNAME = 'scrapy.dev'.freeze

# Define the VM's IP.
# Warning! Do not choose an IP that overlaps with any other IP space on
# your system. This can cause the network not be reachable.
SCRAPY_IP = '192.168.33.100'.freeze

# ------------------------------------------------------------------------------
# Vagrant configuration (do not edit unless you know what you are doing)
# ------------------------------------------------------------------------------

# Minimum tested version.
Vagrant.require_version '>= 1.8.6'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure('2') do |config|
  # ----------------------------------------------------------------------------
  # Global configuration (apply to all VMs)
  # ----------------------------------------------------------------------------

  # Disable shared folders.
  config.vm.synced_folder '.', '/vagrant', type: 'vboxsf', disabled: true

  # Provider-specific configuration (for VirtualBox)
  config.vm.provider 'virtualbox' do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Customize the amount of memory on the VM:
    vb.memory = '2048'

    # Customize the amount of CPUs on the VM:
    vb.cpus = 2
  end

  # Enable forwarding SSH agent on guest VM.
  #
  # On Windows host you have to run first the agent
  #     eval `ssh-agent -s`
  #
  # Add your SSH key to the agent
  #     ssh-add ~/.ssh/id_rsa
  #
  # Note: the forward agent only works when you use the: `vagrant ssh VM_NAME`
  # and not over: `ssh vagrant@PRIVATE_IP`
  #
  # Example: If you want to access a private git repository that you already
  # have access on your host machine with your SSH key.
  # With this method you will your your key on the remote/guest VM, without add
  # it on the guest.
  #
  # If you want to enable forwarding SSH agent, uncomment the following line.
  #
  # config.ssh.forward_agent = true

  # ----------------------------------------------------------------------------
  # Global provision (apply to all VMs)
  # ----------------------------------------------------------------------------

  # Run shell provisioner on every VM.
  config.vm.provision 'shell' do |s|
    # Read your local/host's public SSH key `~/.ssh/id_rsa.pub`.
    SSH_PUBLIC_KEY = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip

    # Execute the inline bash script
    s.inline = <<-SHELL

      # Add your public SSH key to all guest's authorized_keys.
      # This way you can SSH on vagrant VM normally, like: `ssh vagrant@PRIVATE_IP`
      echo "#{SSH_PUBLIC_KEY}" >> /home/vagrant/.ssh/authorized_keys

      # Append on the guest's hosts file the hostname + IP of the guests VMs in
      # order to ping/ssh with hostname, like `ssh vagrant@HOSTNAME`
      echo "#{SCRAPY_IP} #{SCRAPY_HOSTNAME}" >> /etc/hosts

    SHELL
  end

  # ----------------------------------------------------------------------------
  # VMs
  # ----------------------------------------------------------------------------

  # Scrapy Server --------------------------------------------------------------
  config.vm.define 'scrapy' do |scrapy|
    # Every Vagrant development environment requires a box. We use the official
    # Centos 7 box form atlas: https://atlas.hashicorp.com/centos/boxes/7
    scrapy.vm.box = 'centos/7'

    # The hostname the machine should have.
    scrapy.vm.hostname = SCRAPY_HOSTNAME

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    scrapy.vm.network 'private_network', ip: SCRAPY_IP

    # Provision guest VM using Vagrant's shell provisioner.
    scrapy.vm.provision 'shell' do |s|
      # bash commands.
      s.inline = <<-SHELL

        # Create SSH key.
        [ -f /home/vagrant/.ssh/id_rsa ] && echo 'SSH key exist' || ssh-keygen -t rsa -C 'vagrant@#{SCRAPY_HOSTNAME}' -N '' -f /home/vagrant/.ssh/id_rsa

        # Create known_hosts file.
        touch /home/vagrant/.ssh/known_hosts

        # Fix owner.
        chown vagrant:vagrant /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/id_rsa.pub /home/vagrant/.ssh/known_hosts

        # Append on known_hosts of this VM (scrapy.dev) the servers on the network.
        ssh-keyscan -H #{SCRAPY_HOSTNAME}  >> /home/vagrant/.ssh/known_hosts
        ssh-keyscan -H #{SCRAPY_IP}        >> /home/vagrant/.ssh/known_hosts

        # Install EPEL repository (used to install Ansible on Centos).
        if ! rpm -qa | grep -qw epel-release; then
          yum install -y epel-release
        fi

        # Install Ansible.
        if ! rpm -qa | grep -qw ansible; then
          yum install -y ansible
        fi

        # Install git (Used to download the Ansible playbook).
        if ! rpm -qa | grep ^git; then
          yum install -y git
        fi

        # Clone the Ansible playbook
        if [ ! -d "/home/vagrant/ansible-playbook-scrapy" ]; then
          git clone --recursive https://github.com/tovletoglou/ansible-playbook-scrapy.git /home/vagrant/ansible-playbook-scrapy
        fi

        # Change playbook owner
        chown -R vagrant:vagrant /home/vagrant/ansible-playbook-scrapy

      SHELL
    end

    # Print message after VM creation.
    scrapy.vm.post_up_message = "
    -------------------------
    Scrapy server is ready
    IP:       #{SCRAPY_IP}
    Hostname: #{SCRAPY_HOSTNAME}
    -------------------------"
  end
end
