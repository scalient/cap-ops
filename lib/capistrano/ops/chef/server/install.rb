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
      namespace :server do
        desc "Install the Opscode Chef server"
        task :install, roles: :chef_server do
          run "bash",
              data: render(Pathname.new("../../_files/init.sh.erb").expand_path(__FILE__))

          ["chef-expander.conf",
           "chef-server.conf",
           "chef-server-webui.conf",
           "chef-solr.conf",
           "server.rb",
           "solr.rb"].each do |template_file|
            put render(Pathname.new("../_files/#{template_file}.erb").expand_path(__FILE__)),
                "#{fetch(:cache_dir)}/chef/#{template_file}",
                mode: 0644
          end

          ["knife",
           "webui",
           "validation"].each do |name|
            put Pathname.new(fetch("#{name}_key".to_sym)).expand_path(fetch(:config_root)).open { |f| f.read },
                "#{fetch(:cache_dir)}/chef/#{name}.pem",
                mode: 0600
          end

          put Pathname.new("../_files/create_client.rb").expand_path(__FILE__).open { |f| f.read },
              ".chef/plugins/knife/create_client.rb",
              mode: 0644

          run "bash",
              data: render([Pathname.new("../../../_files/includes.sh.erb").expand_path(__FILE__),
                            Pathname.new("../../_files/includes.sh.erb").expand_path(__FILE__),
                            Pathname.new("../_files/install.sh.erb").expand_path(__FILE__)])
        end

        before "ops:chef:server:install", "ops:chef:init"
      end
    end
  end
end
