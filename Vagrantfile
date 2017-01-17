# -*- mode: ruby -*-
# vi: set ft=ruby :

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
    :portforward  => {
      2180 =>  2180
    }
  },
  {
    :name       => "xenial-client",
    :mem        => "1024",
    :cpu        => "1",
    :image      => 'ubuntu/xenial64',
    :internal   => {
      :int1 => "192.168.1.90"
    },
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
        opts[:internal].each do |key, value|
          config.vm.network 'private_network',
            ip: "#{value}",
            virtualbox__intnet: "#{key}"
        end
        config.vm.provision :salt do |salt|
          salt.minion_config = "vagrant/config/minion"
          salt.masterless = true
          salt.run_highstate = false
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
