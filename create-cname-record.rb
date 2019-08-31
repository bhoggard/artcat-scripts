#!/usr/bin/env ruby

require 'dnsimple'

account_id = ENV['DNSIMPLE_ACCOUNT']
client = Dnsimple::Client.new(access_token: ENV['DNSIMPLE_API_KEY'], user_agent: "ArtCat")

domain = ENV['DOMAIN_NAME']
puts domain

cname_name = ENV['CNAME_NAME'].chomp(".#{domain}.")
cname_value = ENV['CNAME_VALUE'].chomp('.')

puts "#{cname_name} => #{cname_value}"


response = client.zones.create_zone_record(account_id, domain, name: cname_name, type: "cname", content: cname_value)

puts response.data.type

