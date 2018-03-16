##########################################################################
# Cookbook Name:: mongodb
# Recipe:: install
##########################################################################

# Setup mongo repo
file '/etc/yum.repos.d/mongodb.repo' do
  content '
    [mongodb]
    name=MongoDB Repository
    baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
    gpgcheck=0
    enabled=1'
end

# Install mongo package
package 'mongodb-org'

# Make sure mongo starts up now and is enabled upon reboot
service 'mongod' do
  action [:enable, :start]
end
