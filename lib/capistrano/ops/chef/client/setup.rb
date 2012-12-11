# -*- coding: utf-8 -*-
#
# Copyright 2012 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require "capistrano"
require "etc"
require "pathname"
require "socket"

Capistrano::Configuration.instance.load do
  namespace :ops do
    namespace :chef do
      namespace :client do
        desc "Set up the Opscode Chef client on the local machine"
        task :setup do
          if !exists?(:chef_server)
            chef_server = find_servers(:roles => :chef_server)[0]
          else
            chef_server = Capistrano::ServerDefinition.new(fetch(:chef_server))
          end

          if exists?(:chef_node_name)
            chef_node_name = fetch(:chef_node_name)
          else
            uid = Process.uid
            uid = ENV["SUDO_UID"].to_i if uid == 0 && ENV.include?("SUDO_UID")
            user = Etc.getpwuid(uid).name
            hostname = Socket.gethostname.split(".", -1)[0]
            chef_node_name = "#{user}-#{hostname}"
          end

          client_rb_file = Pathname.new("/etc/chef/client.rb")
          client_rb_file.dirname.mkpath

          client_rb_file.open("wb") do |f|
            f.write(render(Pathname.new("../_files/client.rb.erb").expand_path(__FILE__),
                           :chef_node_name => chef_node_name,
                           :chef_server => chef_server.host))
          end

          Pathname.new(fetch(:validation_key)).expand_path(fetch(:config_root)).open("rb") do |f1|
            Pathname.new("/etc/chef/validation.pem").open("wb", 0600) do |f2|
              f2.write(f1.read)
            end
          end
        end

        before "ops:chef:client:setup", "ops:chef:init"
      end
    end
  end
end
