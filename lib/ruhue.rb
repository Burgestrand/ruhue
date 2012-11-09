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
    # This sends out a broadcast packet with UDP, and waits for
    # a response from the Hue hub.
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

      Timeout.timeout(timeout, Ruhue::TimeoutError) do
        loop do
          message, (_, _, hue_ip, _) = socket.recvfrom(1024)
          # TODO: improve this. How do we know it’s a Hue hub?
          return new(hue_ip) if message =~ /description\.xml/
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
    Nokogiri::XML(get("/description.xml").body)
  end

  protected

  def request(method, path, *args)
    response = HTTPI.send(method, url(path), *args)
    Ruhue::Response.new(response)
  end
end

require 'ruhue/response'
require 'ruhue/client'
