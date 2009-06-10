#!/usr/bin/ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')
require "jawurflex/wurfl_generator"

puts Jawurflex::WurflGenerator.generate_wurfl
