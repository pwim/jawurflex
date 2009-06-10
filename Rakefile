# (c) 2009 mobalean
#
# Author: Paul McMahon <paul@mobalean.com>,

task :default => ['test:jawurflex']
task :test => ['test:jawurflex']

namespace :test do
  desc "Run the jawurflex test cases"
  task :jawurflex do
    Dir.glob("test/**/*test.rb") {|f| require f if f != __FILE__ }
  end
end

