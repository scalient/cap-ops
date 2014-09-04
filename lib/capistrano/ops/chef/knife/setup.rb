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
      namespace :knife do
        desc "Setup Knife on the local machine"
        task :setup do
          chef_server = find_servers(roles: :chef_server)[0]

          chef_dir = Pathname.new(".chef").expand_path(Dir.home)
          chef_dir.mkpath

          Pathname.new(fetch(:knife_key)).expand_path(fetch(:config_root)).open("rb") do |f1|
            Pathname.new("knife.pem").expand_path(chef_dir).open("wb", 0600) do |f2|
              f2.write(f1.read)
            end
          end

          Pathname.new("knife.rb").expand_path(chef_dir).open("wb") do |f|
            f.write(render(Pathname.new("../_files/knife.rb.erb").expand_path(__FILE__),
                           chef_server: chef_server.host))
          end
        end

        before "ops:chef:knife:setup", "ops:chef:init"
      end
    end
  end
end
