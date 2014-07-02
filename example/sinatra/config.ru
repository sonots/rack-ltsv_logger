require 'logger'
require 'rack/ltsvlogger'
require_relative 'app'

use Rack::LtsvLogger, STDOUT
run App
