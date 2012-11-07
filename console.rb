#!/usr/bin/env ruby
# encoding: utf-8
root = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(root, 'lib')

require 'bundler/setup'
require 'pry'
require 'hue'

def prompt(query)
  print(query)
  gets.chomp.tap { puts }
end

puts <<-HELLO
Hi there!

This is an interpreter to aid experimenting with the Hue. It’s written in Ruby
and makes API calls to the Hue hub a little more pleasant. You’re expected to
know Ruby in order to use this.

I’ll first ask you for your Hue hub username. If you do not have one, just make
one up and I’ll register an application for you on the Hue hub. Use the same
username every time, or you’ll have a lot of unused applications registered to
your Hue after a little while.

First off, I’ll see if I can find your Hue. Give me five seconds at most.
HELLO

hue = Hue.discover
puts
puts "Hue discovered at #{hue.host}!"
puts

username = prompt("Now, your username please (10-40 characters, 0-9, a-z, A-Z): ")
client = Hue::Client.new(hue, username)

puts "Hi #{client.username}!"

if client.registered?
  puts "It appears you’re already registered with the Hub. Play away!"
elsif client.register("ruhue")
  puts "A new application has been registered with the Hub as #{client.username}. Play away!"
end

# Blinks all your lights!
#
# num_lights = 3
# on = true
# 10_000.times do |i|
#   sleep(0.04)
#   light = (i%num_lights) + 1
#   client.put("/lights/#{light}/state", on: on)
#   on = ! on if light == num_lights
# end

binding.pry
