#!/usr/bin/env ruby

# create SSL certificates for a list of domains from a file, one domain per line

require 'aws-sdk'
require 'digest'
require 'dnsimple'
require 'ostruct'

DOMAINS_FILE = File.join(ENV['HOME'], 'data', 'active-domains.txt')

$acm = Aws::ACM::Client.new

$dns_client = Dnsimple::Client.new(access_token: ENV['DNSIMPLE_API_KEY'], user_agent: "ArtCat")

# create certificate and return a list of CNAMEs needed for DNS validation
def create_certificate(domain_name)
  token = Digest::MD5.hexdigest(domain_name)
  response = $acm.request_certificate(
    domain_name: "*.#{domain_name}", 
    validation_method:"DNS", 
    subject_alternative_names: [domain_name], 
    idempotency_token: token
  ) 
  cert_data = $acm.describe_certificate certificate_arn: response.certificate_arn

  cname_records = cert_data.certificate.domain_validation_options.map do |rec|
    OpenStruct.new(name: rec.resource_record.name, value: rec.resource_record.value)
  end

  cname_records.uniq
end

# create CNAME(s) requested for SSL certificate validation
def create_cnames(domain, cname_records)
  account_id = ENV['DNSIMPLE_ACCOUNT']
  cname_records.each do |record|
    cname_name = record.name.chomp(".#{domain}.")
    cname_value = record.value.chomp('.')

    puts "#{record.name} => #{record.value}"
    $dns_client.zones.create_zone_record(account_id, domain, name: cname_name, type: "cname", content: cname_value)
  end
end

#### END OF DEFS ####

File.open(DOMAINS_FILE).each do |domain|
  domain.chomp!
  break if domain.length == 0
  puts domain
  cnames = create_certificate(domain)
  create_cnames(domain, cnames)
end
