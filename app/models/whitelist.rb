require 'socket';
require 'active_support/concern'

class Whitelist < ActiveRecord::Base
    def self.with_reserved
        whitelisted = Whitelist.all.to_a;
        container_ipv4 = Socket.ip_address_list.find { |a| a.ipv4_private? && !a.ipv4_loopback? }.ip_address;
        container_ipv4 = container_ipv4.split('.')[0..2].push('*').join('.')

        local_host = {name: "Localhost", ip: "127.0.0.1", desc: ""}
        local_host_bind = {name: "Localhost Bind", ip: "0.0.0.0", desc: ""}
        local_container = {name: "Container", ip: container_ipv4, desc: ""}
        local_area = {name: "LAN", ip: "192.168.*.*", desc: ""}
        whitelisted.push(local_host, local_host_bind, local_container, local_area);
        return whitelisted;
    end
end