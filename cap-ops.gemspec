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

require "pathname"

$LOAD_PATH.push(Pathname.new("../lib").expand_path(__FILE__).to_s)

require "capistrano/ops/version"

Gem::Specification.new do |s|
  s.name = "cap-ops"
  s.version = Capistrano::Ops::Version.to_s
  s.platform = Gem::Platform::RUBY
  s.licenses = ["Apache-2.0"]
  s.authors = ["Roy Liu"]
  s.email = ["carsomyr@gmail.com"]
  s.homepage = "https://github.com/scalient/cap-ops"
  s.summary = "CapOps is a Capistrano plugin for bootstrapping cloud deployments"
  s.description = "CapOps is a Capistrano plugin for bootstrapping cloud deployments. It automates low-level tasks" \
    " like Opscode Chef server/client installation and other DevOps administration tasks."
  s.add_runtime_dependency "capistrano", ">= 2.12.0"
  s.files = Pathname.glob("lib/**/*.rb").concat(Pathname.glob("bin/*")).map { |f| f.to_s }
  s.test_files = Pathname.glob("{features,spec,test}/*").map { |f| f.to_s }
  s.executables = Pathname.glob("bin/*").map { |f| f.basename.to_s }
  s.require_paths = ["lib"]
end
