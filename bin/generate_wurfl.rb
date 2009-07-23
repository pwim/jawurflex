#!/usr/bin/ruby
require "rubygems"
require "wurfl/loader"
$LOAD_PATH << File.join(File.dirname(__FILE__), '..',  'lib')
require "jawurflex/wurfl_generator"

handsets = Wurfl::Loader.new.load_wurfl(File.join(Jawurflex.data_directory, "wurfl-latest.xml"))

Jawurflex::WurflGenerator.generate_wurfl(handsets, $stdout)
