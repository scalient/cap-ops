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
require "pathname"

Capistrano::Configuration.instance.load do
  namespace :ops do
    namespace :chef do
      namespace :client do
        desc "Install the Opscode Chef client"
        task :install, roles: :chef_client do
          chef_clients = find_servers_for_task(current_task)

          if !exists?(:chef_server)
            chef_server = find_servers(roles: :chef_server)[0]
          else
            chef_server = Capistrano::ServerDefinition.new(fetch(:chef_server))
          end

          if exists?(:chef_node_name)
            raise ArgumentError, "You specified #{chef_clients.size} Chef clients. Please specify exactly one if the" \
              " node name is given" \
              if chef_clients.size != 1

            chef_clients[0].options[:chef_node_name] = fetch(:chef_node_name)
          end

          run "bash",
              data: render(Pathname.new("../../_files/init.sh.erb").expand_path(__FILE__))

          chef_clients.each do |chef_client|
            put render(Pathname.new("../_files/client.rb.erb").expand_path(__FILE__),
                       chef_node_name: chef_client.options[:chef_node_name],
                       chef_server: chef_client.host != chef_server.host ? chef_server.host : "localhost"),
                "#{fetch(:cache_dir)}/chef/client.rb",
                hosts: chef_client.host,
                mode: 0644
          end

          put render(Pathname.new("../_files/chef-client.erb").expand_path(__FILE__)),
              "#{fetch(:cache_dir)}/chef/chef-client",
              mode: 0755

          put Pathname.new(fetch(:validation_key)).expand_path(fetch(:config_root)).open { |f| f.read },
              "#{fetch(:cache_dir)}/chef/validation.pem",
              mode: 0600

          run "bash",
              data: render([Pathname.new("../../../_files/includes.sh.erb").expand_path(__FILE__),
                            Pathname.new("../../_files/includes.sh.erb").expand_path(__FILE__),
                            Pathname.new("../_files/install.sh.erb").expand_path(__FILE__)])
        end

        before "ops:chef:client:install", "ops:chef:init"
      end
    end
  end
end
