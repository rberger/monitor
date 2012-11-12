require "yaml"
current_dir   = File.dirname(__FILE__)

organization  = "runa_test"
username      = ENV['CHEF_USER'] ? ENV['CHEF_USER']: ENV['USER']

log_level                :debug
log_location             STDOUT
node_name                username
client_key               "#{current_dir}/#{username}.pem"
validation_client_name   "#{organization}-validator"
validation_key           "#{current_dir}/#{organization}-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/#{organization}"
chef_server              "https://api.opscode.com/organizations/#{organization}"

cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )

runa_chef_path File.expand_path("#{current_dir}/..")

cluster_chef_path "#{runa_chef_path}"

cluster_path = "#{runa_chef_path}/config/clusters"

keypair_path      File.expand_path("~/.ssh/runa")

cookbook_path ["#{runa_chef_path}/site-cookbooks", "#{runa_chef_path}/cookbooks"]

knife[:ssh_address_attribute] = 'cloud.public_hostname'
knife[:ssh_user] = 'ubuntu'

knife[:bootstrap_runs_chef_client] = true
bootstrap_chef_version   "~> 10.16.2"

aws = YAML.load_file(File.expand_path("~/.aws/aws_config.yml"))
knife[:aws_access_key_id]     = aws['access_key_id']
knife[:aws_secret_access_key] = aws['secret_access_key']
