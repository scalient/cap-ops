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
require "openssl"
require "pathname"

Capistrano::Configuration.instance.load do
  namespace :ops do
    namespace :chef do
      desc "[internal] Initialize the Chef task environment"
      task :init do
        [:knife,
         :validation,
         :webui].each do |name|
          var_name = "#{name}_key".to_sym

          set var_name, fetch(var_name, "chef/#{name}.pem")

          private_key_file = Pathname.new(fetch(var_name)).expand_path(fetch(:config_root))

          if !private_key_file.file?
            logger.info("The private key #{private_key_file.to_s.dump} doesn't exist; creating it now.")

            private_key_file.dirname.mkpath
            private_key_file.open("wb", 0600) { |f| f.write(OpenSSL::PKey::RSA.new(2048).to_pem.to_s) }
          end

          if !exists?(:chef_server)
            chef_servers = find_servers(roles: :chef_server)

            raise ArgumentError, "You specified #{chef_servers.size} Chef servers. Please specify exactly one" \
              if chef_servers.size != 1
          end
        end

        set :chef_server_password, fetch(:chef_server_password, "change me")
      end

      before "ops:chef:init", "ops:init"
    end
  end
end
