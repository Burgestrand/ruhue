#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
Bundler.require

require 'socket'
require 'timeout'

udp = UDPSocket.new(Socket::AF_INET)
udp.send(<<-PACKET, 0, "239.255.255.250", 1900)
M-SEARCH * HTTP/1.1
HOST: 239.255.255.250:1900
MAN: ssdp:discover
MX: 10
ST: ssdp:all
PACKET

hue_ip = nil

begin
  Timeout.timeout(5) do
    _, _, hue_ip, _ = loop do
      message, packet = udp.recvfrom(1024)
      # TODO: improve this. How do we know it’s a Hue hub?
      break packet if message =~ /description\.xml/
    end
  end
rescue TimeoutError
  abort "Could not find Hue bridge."
end

request = HTTPI.get("http://#{hue_ip}/description.xml")
xml = Nokogiri::XML(request.body)

binding.pry
