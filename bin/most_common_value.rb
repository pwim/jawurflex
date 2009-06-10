#!/usr/bin/ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')
carrier = ARGV[0]
require "jawurflex/handset/#{carrier}_handset"

handsets = Jawurflex::Handset.const_get(carrier.capitalize << "Handset").parse_handsets
h = Hash.new(0)
handsets.each do |handset|
  h[handset.send(ARGV[1])] += 1
end
v, i = h.max {|a,b| a[1] <=> b[1]}
puts "Attribute #{ARGV[1]} is most common value is #{v}, appearing #{i} times."
