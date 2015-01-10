#
# Cookbook Name:: phantomJs
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

execute 'apt-get-update' do
  command 'apt-get update'
end

package 'fonts-beteckna'
package 'openjdk-7-jre'
package 'unzip'
package 'supervisor'

remote_file '/opt/selenium-server-standalone.jar' do
  source "http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar" 
  action :create
  mode 0644
end

remote_file '/tmp/phantomjs.tar.bz2' do
  source "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2"
  action :create
  notifies :run, "execute[unpack phantomjs]", :immediately
end

execute "unpack phantomjs" do
  command "tar xjf /tmp/phantomjs.tar.bz2 -C /opt/."
  action :nothing
  notifies :run, "execute[mv phantomjs]", :immediately
end

execute 'mv phantomjs' do
  command "mv /opt/phantomjs-1.9.8-linux-x86_64 /opt/phantomjs"
  action :nothing
  notifies :restart, 'service[supervisor]'
end


template '/etc/supervisor/conf.d/phantomJs.conf' do
  source 'supervisord.conf.erb'
  notifies :restart, 'service[supervisor]'
end

service 'supervisor' do
  action :start
end
