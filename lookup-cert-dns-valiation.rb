#!/usr/bin/env ruby

require 'aws-sdk'
require 'ostruct'

acm = Aws::ACM::Client.new

resp = OpenStruct.new(certificate_arn: ENV['CERT_ARN'])
cert_data = acm.describe_certificate certificate_arn: resp.certificate_arn

cname_records = cert_data.certificate.domain_validation_options.map do |rec|
  OpenStruct.new(name: rec.resource_record.name, value: rec.resource_record.value)
end

puts cname_records.uniq
