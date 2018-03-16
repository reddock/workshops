#
# Cookbook:: install_tomcat
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# But when the group specified doesn't exist, it complains as expected
user 'tomcat' do
  shell '/sbin/nologin'
  home '/opt/tomcat'
end

# Create the group tomcat and add the user tomcat
group 'tomcat' do
  members 'tomcat'
end

# This version didn't exist on apache.cs.utah.edu so went with the latest 
remote_file '/tmp/apache-tomcat-8.5.29.tar.gz' do
  source 'http://apache.cs.utah.edu/tomcat/tomcat-8/v8.5.29/bin/apache-tomcat-8.5.29.tar.gz'
  owner 'ec2-user'
  group 'ec2-user'
  mode '755'
end

# Make directory for tomcat
directory '/opt/tomcat' do
  owner 'root'
  group 'root'
  mode '0755'
end

# Shamelessly stolen from stackoverflow
execute 'extract_some_tar' do
  command 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
  cwd '/tmp'
  not_if { File.exists?("/file/contained/in/tar/here") }
end

# I hit an error here because I had recursive True
# with a capital T as noted in the documentation at the link below
# https://docs.chef.io/resource_directory.html
# But the True needs to have a lowercase t
# Maybe I'm just reading the documentation wrong. I see the example further below
#   in the documentation with a lowercase t
#
#   This changing the group owner of everything below /opt/tomcat to tomcat
directory '/opt/tomcat' do
  group 'tomcat'
  recursive true
end

# Adding group run permission to everything below conf 
directory '/opt/tomcat/conf' do
  mode '0640'
  recursive true
end

# Giving group execute permission to everything below conf
directory '/opt/tomcat/conf' do
  mode '0650'
end

# Using this fancy loop to change all the group ownernship to everything
#   below these directories 
%w[ /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs ].each do |path|
  directory path do
    owner 'tomcat'
    recursive true
  end
end

end

template '/etc/systemd/system/tomcat.service' do
  mode '0755'
  source 'tomcat.service.erb'
  owner 'root'
  group 'root'
  action :create
end

service 'tomcat.service' do
  action [ :enable, :start ]
end
