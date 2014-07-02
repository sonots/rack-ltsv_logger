require 'socket'
require 'time'

module Rack
  class LtsvLogger
    HOST_IP = Socket.getaddrinfo(Socket::gethostname, nil, Socket::AF_INET)[0][3]
    PID = Process.pid

    def initialize(app, logger=nil)
      @app = app
      @logger = logger || $stdout
    end

    def call(env)
      start_time = Time.now.instance_eval { to_i + (usec/1000000.0) }

      status, headers, body = @app.call(env)

      now = Time.now
      time = now.iso8601
      request_time = now.instance_eval { to_i + (usec/1000000.0) } - start_time

      params = {
        time: time,
        pid: PID,
        host: HOST_IP,
        size: body.to_s.bytesize,
        status: status,
        method: env['REQUEST_METHOD'],
        uri: env['PATH_INFO'],
        reqtime: request_time,
      }
      @logger.write ltsv(params)

      [status, headers, body]
    end

    private

    def ltsv(hash)
      hash.map {|k, v| "#{k}:#{v}" }.join("\t") + "\n"
    end
  end
end
