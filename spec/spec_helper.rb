# spec/awesome_gem/awesome.rb
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$: << File.join(APP_ROOT, 'lib')

require 'coveralls'
Coveralls.wear!

require 'pry-debugger'
require 'has_lineage'
