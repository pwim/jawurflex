#!/usr/bin/ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')
carrier = ARGV[0]
require "jawurflex/handset/#{carrier}_handset"

puts Jawurflex::Handset.const_get(carrier.capitalize << "Handset").parse_handsets.to_yaml

