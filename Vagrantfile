# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'berkshelf/vagrant'

default = {
  :user => ENV['OPSCODE_USER'] || ENV['USER'],
  :base_box => ENV['VAGRANT_BOX'] || "precise64",
  :orgname =>  ENV['ORGNAME'] || 'runa_test',
  :host_user => ENV['USER'],
  :host_user_home => ENV['HOME'],
  :runa_box_url =>"http://10.0.1.6:8000",
  :vm_memory => "2048",
  :host_hostname => `hostname`.split(".")[0].tr('-','_').chomp,
  :name_offset => 0,
  :vm_network_address => "33.33.33.20",
  :flavor => "monitor"
}

vm_hostname = "#{default[:user]}-#{default[:host_hostname]}#{default[:name_offset]}-runastack"

# nodename format <flavor><index>-dev<index>-user.host
CLUSTER_NAME = "dev#{default[:name_offset]}-#{default[:user]}_#{default[:host_hostname]}"
VM_NODENAME = "#{default[:flavor]}#{default[:name_offset]}-#{CLUSTER_NAME}"

uid = `id -u #{default[:host_user]}`
gid = `id -g #{default[:host_user]}`

unless system "knife node list > /dev/null"
  puts "You must have your knife.rb configured. Usually in .chef/knife.rb or ~/.chef/knife.rb"
  puts "You can probably copy it from runa_cookbooks/.chef/knife.rb"
  puts "You will also need to have #{default[:host_user_home]}/.chef/#{default[:orgname]}-validator.pem"
  exit(-1)
end

Vagrant::Config.run do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #  config.vm.box = "base"
  config.vm.box = default[:base_box]
  
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"
  config.vm.box_url = "#{default[:runa_box_url]}/#{default[:base_box]}.box"
  
  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"
  config.vm.network :hostonly, default[:vm_network_address]
  
  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  # config.vm.forward_port 80, 8080

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  config.vm.network :hostonly, default[:vm_network_address]

  config.vm.customize [
                       "modifyvm", :id,
                       "--memory", default[:vm_memory],
                       "--name", vm_hostname
                      ]
  
  config.vm.host_name = vm_hostname
  
  config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "https://api.opscode.com/organizations/#{default[:orgname]}"
    chef.validation_key_path = "#{default[:host_user_home]}/.chef/#{default[:orgname]}-validator.pem"
    chef.validation_client_name = "runa_test-validator"
    chef.client_key_path = "/etc/chef/client.pem"
    chef.environment = "dev"
    
    chef.node_name = VM_NODENAME
    chef.run_list = [
                     "recipe[graphite]",
                     "recipe[statsd]"
                    ]
  end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # IF you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"

  require 'vagrant/provisioners/chef_client'

  module Vagrant
    module Provisioners
      class ChefClient < Chef
        def cleanup
          puts `sh -c 'knife client delete #{VM_NODENAME} -y'`
          puts `sh -c 'knife node delete #{VM_NODENAME} -y'`
        end
      end
    end
  end
end
