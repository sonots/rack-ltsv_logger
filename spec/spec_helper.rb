require 'bundler'
Bundler.setup(:default, :test)
Bundler.require(:default, :test)
require 'timecop'

#require 'simplecov'
#require 'simplecov-rcov'
#SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
#SimpleCov.start

$TESTING=true
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/rack/')
require 'rack-ltsvlogger'
