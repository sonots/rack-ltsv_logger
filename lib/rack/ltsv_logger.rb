require 'time'

module Rack
  class LtsvLogger
    DEFAULT_PARAMS_PROC = Proc.new do |env, status, headers, body, began_at|
      now = Time.now
      reqtime = now.instance_eval { to_i + (usec/1000000.0) } - began_at
      {
        time: now.iso8601,
        pid: Process.pid,
        host: env["REMOTE_ADDR"] || "-",
        forwardedfor: env['HTTP_X_FORWARDED_FOR'] || "-",
        user: env["REMOTE_USER"] || "-",
        method: env["REQUEST_METHOD"],
        uri: env["PATH_INFO"],
        query: env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
        protocol: env["HTTP_VERSION"],
        status: ::Rack::LtsvLogger.extract_status(status),
        size: ::Rack::LtsvLogger.extract_content_length(headers),
        reqtime: "%0.6f" % reqtime,
      }
    end

    def initialize(app, io = nil, **kwargs)
      @app = app
      @io = io || $stdout
      @params_proc = kwargs[:params_proc] || DEFAULT_PARAMS_PROC
      @appends = kwargs.tap {|h| h.delete(:params_proc) } # old version compatibility
    end

    def call(env)
      began_at = Time.now.instance_eval { to_i + (usec/1000000.0) }
      status, headers, body = @app.call(env)
    ensure
      params = @params_proc.call(env, status, headers, body, began_at)
      @appends.each {|key, proc| params[key] = proc.call(env) } # old version compatibility
      @io.write ltsv(params)
    end

    def self.extract_content_length(headers)
      value = headers && headers['Content-Length'] or return '-'
      value.to_s == '0' ? '-' : value
    end

    def self.extract_status(status)
      status.nil? ? "500" : status.to_s[0..3]
    end

    private

    def ltsv(hash)
      hash.map {|k, v| "#{k}:#{v}" }.join("\t") + "\n"
    end
  end
end
