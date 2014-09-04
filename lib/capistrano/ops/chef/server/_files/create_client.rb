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

class Chef
  class Knife
    # One drawback of using vanilla Chef tools is that there's no easy way to make the server accept user-generated
    # client keys. Instead, the user must rely on an initial run of the Chef server to generate the validation.pem and
    # webui.pem keys. Consequently, this monkey patch extends `knife client create` functionality and enables
    # user-generated client keys to be set directly on the local CouchDB instance.
    #
    # If the user specifies a private key via the `--private-key` option, the operation will be run against the local
    # CouchDB instance. Otherwise, processing proceeds as it would without the patch.
    class ClientCreate < Knife
      deps do
        require "chef/api_client"
        require "chef/config"
        require "chef/couchdb"
        require "chef/exceptions"
        require "chef/json_compat"
        require "openssl"
        require "pathname"
      end

      option :private_key,
             short: "-p PRIVATE_KEY",
             long: "--private-key PRIVATE_KEY",
             description: "The user-generated private key"

      run_method = instance_method(:run)

      define_method(:run) do
        Chef::CouchDB.new.create_db
        Chef::CouchDB.new.create_id_map

        name = @name_args[0]

        if name.nil?
          show_usage
          ui.fatal("Please provide the client name")
          exit 1
        end

        filename = config[:private_key]

        if !filename.nil?
          begin
            client = Chef::ApiClient.cdb_load(name)
          rescue Chef::Exceptions::CouchDBNotFound
            client = Chef::ApiClient.new
            client.name(name)
          end

          client.admin(config[:admin])

          key = OpenSSL::PKey::RSA.new(filename != "-" ? Pathname.new(filename).open { |f| f.read } : STDIN.read)
          client.public_key(key.public_key.to_pem.to_s)
          client.private_key(key.to_pem.to_s)

          client.cdb_save
        else
          run_method.bind(self).call
        end
      end
    end
  end
end
