require 'time'

module Rack
  class LtsvLogger
    PID = Process.pid

    def initialize(app, logger=nil, appends = {})
      @app = app
      @logger = logger || $stdout
      @appends = appends
    end

    def call(env)
      began_at = Time.now.instance_eval { to_i + (usec/1000000.0) }

      status, headers, body = @app.call(env)
    ensure
      now = Time.now
      reqtime = now.instance_eval { to_i + (usec/1000000.0) } - began_at

      params = {
        time: now.iso8601,
        pid: PID,
        host: env["REMOTE_ADDR"] || "-",
        forwardedfor: env['HTTP_X_FORWARDED_FOR'] || "-",
        user: env["REMOTE_USER"] || "-",
        method: env["REQUEST_METHOD"],
        uri: env["PATH_INFO"],
        query: env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
        protocol: env["HTTP_VERSION"],
        status: extract_status(status),
        size: extract_content_length(headers),
        reqtime: "%0.6f" % reqtime,
      }
      @appends.each do |key, proc|
        params[key] = proc.call(env)
      end
      @logger.write ltsv(params)

      [status, headers, body]
    end

    private

    def ltsv(hash)
      hash.map {|k, v| "#{k}:#{v}" }.join("\t") + "\n"
    end

    def extract_content_length(headers)
      value = headers && headers['Content-Length'] or return '-'
      value.to_s == '0' ? '-' : value
    end

    def extract_status(status)
      status.nil? ? "500" : status.to_s[0..3]
    end
  end
end
