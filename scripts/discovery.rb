#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
Bundler.require

require 'socket'
require 'timeout'
require 'json'

class Hue
  TimeoutError = Class.new(TimeoutError)

  class << self
    def discover(timeout = 5)
      socket  = UDPSocket.new(Socket::AF_INET)
      payload = []
      payload << "M-SEARCH * HTTP/1.1"
      payload << "HOST: 239.255.255.250:1900"
      payload << "MAN: ssdp:discover"
      payload << "MX: 10"
      payload << "ST: ssdp:all"
      socket.send(payload.join("\n"), 0, "239.255.255.250", 1900)

      Timeout.timeout(timeout, Hue::TimeoutError) do
        loop do
          message, (_, _, hue_ip, _) = socket.recvfrom(1024)
          # TODO: improve this. How do we know it’s a Hue hub?
          return new(hue_ip) if message =~ /description\.xml/
        end
      end
    rescue TimeoutError
      nil
    end
  end

  # @example
  #   hue = Hue.new("192.168.0.21")
  #
  # @param [String] host address to the Hue hub.
  def initialize(host)
    @host = host.to_str
  end

  # @return [String] hue host
  attr_reader :host

  # @param [String] path
  # @return [String] full url
  def url(path)
    "http://#{host}/#{path.to_s.sub(/\A\//, "")}"
  end

  # GET a path of the Hue.
  #
  # @param [String] path
  # @return [HTTPI::Response]
  def get(path)
    HTTPI.get(url(path))
  end

  # GET a path of the Hue.
  #
  # @param [String] path
  # @param data json-serializable
  # @return [HTTPI::Response]
  def post(path, data)
    HTTPI.post(url(path), JSON.dump(data))
  end

  # @return [Nokogiri::XML] Hue device description
  def description
    Nokogiri::XML(get("/description.xml").body)
  end
end

hue = Hue.discover

binding.pry
