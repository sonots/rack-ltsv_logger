require 'logger'
require 'rack/ltsv_logger'
require_relative 'app'

params_proc = Proc.new do |env, status, headers, body, began_at|
  params = Rack::LtsvLogger::DEFAULT_PARAMS_PROC.call(env, status, headers, body, began_at)
  params.delete(:protocol)
  params.merge!({
    vhost: env['HTTP_HOST'] || "-",
    ua: env['HTTP_USER_AGENT'] || "-",
    referer: env['HTTP_REFERER'] || "-",
  })
end
use Rack::LtsvLogger, $stdout, params_proc: params_proc
run App
