#!/usr/bin/env ruby
# encoding: utf-8

require 'httpi'
require 'nokogiri'
require 'socket'
require 'timeout'
require 'json'

class Ruhue
  TimeoutError = Class.new(TimeoutError)
  APIError = Class.new(StandardError)

  class << self
    # Search for a Hue hub, with configurable timeout.
    #
    # This sends out a broadcast SSDP packet with UDP, and waits
    # for a response from the Hue hub.
    #
    # @param [Integer] timeout seconds until giving up
    # @raise [Ruhue::TimeoutError] in case timeout is reached
    # @return [Hub]
    def discover(timeout = 5)
      socket  = UDPSocket.new(Socket::AF_INET)
      payload = []
      payload << "M-SEARCH * HTTP/1.1"
      payload << "HOST: 239.255.255.250:1900"
      payload << "MAN: ssdp:discover"
      payload << "MX: 10"
      payload << "ST: ssdp:all"
      socket.send(payload.join("\n"), 0, "239.255.255.250", 1900)

      # TODO: Support multiple hubs by using SN from UUID or description.xml
      # TODO: Parse HTTP response for LOCATION: header
      begin
	Timeout.timeout(timeout, Ruhue::TimeoutError) do
	  loop do
	    message, (_, _, hue_ip, _) = socket.recvfrom(2048)
	    # TODO: Use ST: uuid:2f402f80-da50-11e1-9b23-[serial] ?
	    if message =~ /description.xml/
	      hue = new(hue_ip)
	      desc = hue.description
	      return hue if desc.css('modelName').text =~ /Philips hue/i
	    end
	  end
	end
      end
    end
  end

  # @example
  #   hue = Ruhue.new("192.168.0.21")
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
  # @return [Ruhue::Response]
  def get(path)
    request(:get, path)
  end

  # POST a payload to the Hue.
  #
  # @param [String] path
  # @param data json-serializable
  # @return [Ruhue::Response]
  def post(path, data)
    request(:post, path, JSON.dump(data))
  end

  # PUT a payload to the Hue.
  #
  # @param [String] path
  # @param data json-serializable
  # @return [Ruhue::Response]
  def put(path, data)
    request(:put, path, JSON.dump(data))
  end

  # DELETE a resource.
  #
  # @param [String] path
  # @return [Ruhue::Response]
  def delete(path)
    request(:delete, path)
  end

  # @return [Nokogiri::XML] Hue device description
  def description
    response = HTTPI.send("get", url("/description.xml"))
    Nokogiri::XML(response.body) { |config| config.nonet }
  end

  protected

  def request(method, path, *args)
    response = HTTPI.send(method, url(path), *args)
    Ruhue::Response.new(response)
  end
end

require 'ruhue/response'
require 'ruhue/client'
