#!/usr/bin/env ruby
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

ENV["BUNDLE_GEMFILE"] ||= "/home/chef/client/Gemfile"

require "rubygems"
require "bundler"

Bundler.setup

# Scrub the environment to make it more friendly for processes spawned by the Chef client.
ENV.delete("BUNDLE_BIN_PATH")
ENV.delete("GEM_HOME")
ENV.delete("GEM_PATH")
ENV.delete("RUBYOPT")

load Gem.bin_path("chef", "chef-client")
