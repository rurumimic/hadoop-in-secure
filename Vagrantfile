# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "centos/7"

  config.vm.define vm_name = "my" do |config|
    config.vm.hostname = "my"
    
    config.vm.network :forwarded_port, guest: 9870, host: 9870   # NameNode
    config.vm.network :forwarded_port, guest: 8088, host: 8088   # ResourceManager
    config.vm.network :forwarded_port, guest: 19888, host: 19888 # MapReduce JobHistory Server

    config.vm.network :private_network, ip: "192.168.9.100"

    config.vm.provider :virtualbox do |vb|
      vb.memory = 4096
      vb.cpus = 4
    end
    config.vm.provision :ansible do |ansible|
      ansible.playbook = "ansible/playbook.yaml"
      ansible.limit = "all"
    end
  end

end