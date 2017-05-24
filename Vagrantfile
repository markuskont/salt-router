# -*- mode: ruby -*-
# vi: set ft=ruby :

MASTER_IP = '192.168.1.10'
SALT = 'stable' # stable|git|daily|testing

boxes = [
  {
    :name         => "xenial-r1",
    :mem          => "1024",
    :cpu          => "1",
    :image        => 'ubuntu/xenial64',
    :internal     => {
      :int1 => "192.168.1.254",
      :int2 => "192.168.2.254"
    },
    :salt         => true,
    :saltmaster   => false,
    :portforward  => {
      2180 =>  2180
    }
  },
  {
    :name         => "jessie-r1",
    :mem          => "1024",
    :cpu          => "1",
    :image        => 'debian/jessie64',
    :internal     => {
      :int1 => "192.168.1.253",
      :int2 => "192.168.2.253"
    },
    :salt         => true,
    :saltmaster   => false,
    :portforward  => {
      2180 =>  2180
    }
  },
#  {
#    :name       => "xenial-client",
#    :mem        => "1024",
#    :cpu        => "1",
#    :image      => 'ubuntu/xenial64',
#    :internal   => {
#      :int1 => "192.168.1.90"
#    },
#    :salt       => true,
#    :saltmaster => false
#  },
  {
    :name       => "saltmaster",
    :mem        => "1024",
    :cpu        => "2",
    :internal   => {
      :int1 => MASTER_IP
    },
    :image      => "ubuntu/xenial64",
    :salt       => true,
    :saltmaster => true
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
      config.vm.provision "shell",
        inline: "grep salt /etc/hosts || sudo echo \"#{MASTER_IP}\"  salt >> /etc/hosts"
      if opts[:salt] == true
        opts[:internal].each do |key, value|
          config.vm.network 'private_network',
            ip: "#{value}",
            virtualbox__intnet: "#{key}"
        end
        config.vm.provision :salt do |salt|
          salt.minion_config = "vagrant/config/minion"
          salt.masterless = false
          salt.run_highstate = false
          salt.install_type = SALT
          salt.install_master = opts[:saltmaster]
          if opts[:saltmaster] == true
            salt.master_config = "vagrant/config/master"
          end
        end
        if opts.has_key? :portforward
          opts[:portforward].each do |key, value|
            config.vm.network "forwarded_port",
              guest: value,
              host: key
          end
        end
      end
    end
  end
end
