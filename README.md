# Scrapy Vagrant blueprint on Centos 7

## Workflow

1. Start the VM. Execute from: `local@host_machine`

  ```
  vagrant up
  ```

2. Map on the host's `hosts` file the IP of the guest VM. Edit the `/etc/hosts` on Linux or `C:\Windows\System32\drivers\etc\hosts` on Windows and add:

  ```
  # Vagrant
  192.168.33.100 scrapy.dev
  ```

3. Add on host's `known_hosts` the public key of the guest VM.

  ```
  ssh-keyscan -t rsa $i 2>&1 | \grep -v '#' | sort -u - ~/.ssh/known_hosts > ~/.ssh/tmp_known_hosts
  mv ~/.ssh/tmp_known_hosts ~/.ssh/known_hosts
  ```

4. Add on guest's `known_hosts` the public key of the guest VM.

  ```
  scp vagrant@scrapy.dev:/home/vagrant/.ssh/id_rsa.pub ./tmp/scrapy_server_id_rsa.pub
  ssh vagrant@scrapy.dev "cat >> /home/vagrant/.ssh/authorized_keys" < ./tmp/scrapy_server_id_rsa.pub
  ```

5. Login

  ```
  # Login over normal SSH using the keys we just applied
  ssh vagrant@scrapy.dev

  # Or login using Vagrant SSH
  vagrant ssh
  ```

6. Run the Ansible provisioning inside the VM.

  ```
  cd /home/vagrant/ansible-playbook-scrapy/

  # Run the fisrt playbook in order to download the ansible roles
  ansible-playbook -i hosts playbook_ansible.yml

  # Run the actual playbook that will apply the configuration and set up scrapy
  ansible-playbook -i hosts playbook_scrapy.yml
  ```

If you are executing the commands on Windows under `MINGW32` or any other Linux-like shells (strongly suggested to work on [bash-git-for-windows](https://git-scm.com/download/win)) you can run the `after-boot-script.sh` script (it replicates the steps 2 to 4)

```
./after-boot-script.sh
```
