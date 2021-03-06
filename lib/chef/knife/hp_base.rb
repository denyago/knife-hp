#
# Author:: Matt Ray (<matt@opscode.com>)
# Copyright:: Copyright (c) 2012-2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'fog'

class Chef
  class Knife
    module HpBase

      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'chef/json_compat'
            require 'chef/knife'
            require 'readline'
            Chef::Knife.load_deps
          end

          option :hp_access_key,
          :short => "-A ID",
          :long => "--hp-access ID",
          :description => "Your HP Cloud Access Key ID",
          :proc => Proc.new { |key| Chef::Config[:knife][:hp_access_key] = key }

          option :hp_secret_key,
          :short => "-K SECRET",
          :long => "--hp-secret SECRET",
          :description => "Your HP Cloud Secret Key",
          :proc => Proc.new { |key| Chef::Config[:knife][:hp_secret_key] = key }

          option :hp_tenant_id,
          :short => "-T ID",
          :long => "--hp-tenant ID",
          :description => "Your HP Cloud Tenant ID",
          :proc => Proc.new { |key| Chef::Config[:knife][:hp_tenant_id] = key }

          option :hp_auth_uri,
          :long => "--hp-auth URI",
          :description => "Your HP Cloud Auth URI",
          :default => "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/",
          :proc => Proc.new { |endpoint| Chef::Config[:knife][:hp_auth_uri] = endpoint }

          option :hp_avl_zone,
          :short => "-Z Zone",
          :long => "--hp-zone Zone",
          :default => "az1",
          :description => "Your HP Cloud Availability Zone (az1/az2/az3)",
          :proc => Proc.new { |key| Chef::Config[:knife][:hp_avl_zone] = key }
        end
      end

      def connection
        Chef::Log.debug("hp_access_key: #{Chef::Config[:knife][:hp_access_key]}")
        Chef::Log.debug("hp_secret_key: #{Chef::Config[:knife][:hp_secret_key]}")
        Chef::Log.debug("hp_tenant_id: #{Chef::Config[:knife][:hp_tenant_id]}")
        Chef::Log.debug("hp_auth_uri: #{locate_config_value(:hp_auth_uri)}")
        Chef::Log.debug("hp_avl_zone: #{availability_zone()}")
        @connection ||= begin
                          connection = Fog::Compute.new(
            :provider => 'HP',
            :hp_access_key => Chef::Config[:knife][:hp_access_key],
            :hp_secret_key => Chef::Config[:knife][:hp_secret_key],
            :hp_tenant_id => Chef::Config[:knife][:hp_tenant_id],
            :hp_auth_uri => locate_config_value(:hp_auth_uri),
            :hp_avl_zone => availability_zone()
            )
                        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!(keys=[:hp_access_key, :hp_secret_key, :hp_tenant_id])
        errors = []

        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(hp)/i) ? w.upcase  : w.capitalize }
          if Chef::Config[:knife][k].nil?
            errors << "You did not provided a valid '#{pretty_key}' value."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end

      def availability_zone()
        case locate_config_value(:hp_avl_zone)
        when 'az3'
          return 'az-3.region-a.geo-1'
        when 'az2'
          return 'az-2.region-a.geo-1'
        else
          return 'az-1.region-a.geo-1'
        end
      end

    end
  end
end


