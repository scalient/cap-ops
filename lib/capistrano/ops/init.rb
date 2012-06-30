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

Capistrano::Configuration.instance.load do
  namespace :ops do
    desc "[internal] Initialize the CapOps task environment"
    task :init do
      set :cache_dir, fetch(:cache_dir, ".cache/ops")
      set :config_root, fetch(:config_root, "config/ops")

      Pathname.new(fetch(:config_root)).mkpath

      set :prefix, fetch(:prefix, "/usr/local")
      set :user, fetch(:user, "ubuntu")
    end
  end
end
