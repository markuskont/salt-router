# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = [
  {
    :name       => "xenial",
    :mem        => "1024",
    :cpu        => "1",
    :image      => 'ubuntu/xenial64',
    :internal   => [
      "192.168.1.254",
      "192.168.2.254"
    ],
    :salt       => true
  }
]

Vagrant.configure(2) do |config|
  boxes.each do |opts|
    config.vm.define opts[:name] do |config|
      config.vm.box = opts[:image]
      config.vm.hostname = opts[:name]
      #config.vm.synced_folder "salt/", "/srv/salt/"
      config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
      if opts[:salt] == true
        opts[:internal].each do |ip|
          config.vm.network 'private_network',
            ip: ip
        end
        config.vm.network "forwarded_port",
          guest: 2180,
          host: 2180
        config.vm.provision :salt do |salt|
          salt.minion_config = "vagrant/config/minion"
          salt.masterless = true
          salt.run_highstate = false
        end
      end
    end
  end
end
