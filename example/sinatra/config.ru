require 'logger'
require 'rack/ltsv_logger'
require_relative 'app'

use Rack::LtsvLogger, STDOUT
run App
