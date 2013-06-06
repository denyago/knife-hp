#
# Author:: Matt Ray (<matt@opscode.com>)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

require 'chef/knife/hp_base'

class Chef
  class Knife
    class HpIpList < Knife

      include Knife::HpBase

      banner "knife hp ip list"

      def run

        validate!

        ip_list = [
          ui.color('ID', :bold),
          ui.color('Address', :bold),
          ui.color('Fixed IP', :bold),
          ui.color('Instance ID', :bold),
        ]

        connection.addresses.sort_by do |ip|
          [ip.id, ip.ip].compact
        end.each do |ip|
          ip_list << ip.id
          ip_list << ip.ip
          ip_list << ip.fixed_ip
          ip_list << ip.instance_id
        end

        ip_list = ip_list.map do |ip|
          ip.to_s
        end

        puts ui.list(ip_list, :uneven_columns_across, 4)
      end
    end
  end
end
