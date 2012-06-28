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
require "erb"
require "ostruct"
require "pathname"
require "shellwords"

module Capistrano
  module Ops
    # A support class for {Dsl#render} that extends `OpenStruct` and falls back to Capistrano configuration variables
    # when an accessor has no value.
    class ConfigurationStruct < OpenStruct
      # The constructor.
      #
      # @param [Hash] hash_binding the hash binding of values.
      # @param [Configuration] configuration the Capistrano configuration instance.
      def initialize(hash_binding, configuration)
        super(hash_binding)
        @configuration = configuration
      end

      # Defers to the underlying Capistrano configuration instance when an accessor has no value.
      def method_missing(name, *args, &block)
        if args.empty? && name != :[]
          begin
            @configuration.fetch(name)
          rescue IndexError
            @configuration.send(name, *args, &block)
          end
        else
          super
        end
      end

      # Defers to the underlying Capistrano configuration instance if the superclass method doesn't respond.
      def respond_to?(name)
        super || @configuration.respond_to?(name)
      end
    end

    module Dsl
      # Renders the given template(s) in the context of a {ConfigurationStruct}.
      #
      # @param [Array] template_files the template(s) to render.
      # @param [Hash] hash_binding the hash binding of values.
      #
      # @return [String] the concatenation of the rendered templates.
      def render(template_files, hash_binding = {})
        template_files = [template_files] if !template_files.is_a?(Array)
        template_files = template_files.map do |template_file|
          template_file.is_a?(String) ? Pathname.new(template_file) : template_file
        end

        binding = ConfigurationStruct.new(hash_binding, self).instance_eval { binding() }
        template_files.map do |template_file|
          ERB.new(template_file.open("rb") { |f| f.read }, nil, "-").result(binding)
        end.join("")
      end
    end
  end
end

Capistrano::Configuration.instance.load do
  class << self
    include Capistrano::Ops::Dsl
  end
end
