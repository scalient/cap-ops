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
        desc "Run the Opscode Chef client"
        task :update, roles: :chef_client do
          run "bash",
              data: render(Pathname.new("../../_files/init.sh.erb").expand_path(__FILE__))

          run "bash",
              data: render(Pathname.new("../_files/update.sh.erb").expand_path(__FILE__))
        end

        before "ops:chef:client:update", "ops:chef:init"
      end
    end
  end
end
