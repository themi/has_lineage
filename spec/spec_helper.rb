# spec/awesome_gem/awesome.rb
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$: << File.join(APP_ROOT, 'lib')

require 'has_lineage'
