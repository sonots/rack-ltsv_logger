require 'time'

module Rack
  class LtsvLogger
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
        host: env['REMOTE_ADDR'] || "-",
        vhost: env['HTTP_HOST'] || "-",
        forwardedfor: env['HTTP_X_FORWARDED_FOR'] || "-",
        size: extract_content_length(headers),
        status: status,
        method: env['REQUEST_METHOD'] || "-",
        uri: env['PATH_INFO'] || "-",
        ua: env['HTTP_USER_AGENT'] || "-",
        referer: env['HTTP_REFERER'] || "-",
        reqtime: request_time,
      }
      @logger.write ltsv(params)

      [status, headers, body]
    end

    private

    def ltsv(hash)
      hash.map {|k, v| "#{k}:#{v}" }.join("\t") + "\n"
    end

    def extract_content_length(headers)
      value = headers['Content-Length'] or return '-'
      value.to_s == '0' ? '-' : value
    end
  end
end
