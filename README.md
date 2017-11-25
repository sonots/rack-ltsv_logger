# Rack::LtsvLogger

A rack middleware to output access log in ltsv format, like [rack/commonlogger](https://github.com/rack/rack/blob/master/lib/rack/commonlogger.rb) (which output access log in apache common format).

## Why Rack Middleware

cf. https://speakerdeck.com/mirakui/high-performance-rails-long-edition

<img src="doc/x_runtime.png" alt="x_runtime" width="50%" height="50%"/>

The Completed Time, which the default logger of rails shows,
does not include the routing time, and the elapsed time on rack middleware layers.
To measure the processing time accurately,
it is necessary to insert a rack middleware at the head of rack middleware stacks.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-ltsv_logger'

And then execute:

    $ bundle

## How to Use

Insert Rack::LtsvLogger on the head of rack middlewares. 

### Rails

```ruby
# config/application.rb
class Application < Rails::Application
  config.middleware.insert_after(0, Rack::LtsvLogger, $stdout)
end
```

Middleware check.

```
bundle exec rake middleware
```

### Sinatra

```ruby
# config.ru
require 'rack/ltsv_logger'

use Rack::LtsvLogger, $stdout
run App
```

## Format

Sample (line feeded, but actually tab seperated):

```
time:2014-07-02T21:52:31+09:00
pid:15189
host:127.0.0.1
forwardedfor:127.0.0.2
user:user
method:GET
uri:/get
query:?foo
protocol:HTTP/1.1
status:200
size:-
reqtime:0.000000
```

### Default Fields

| key          | value                                                                          |
|--------------|--------------------------------------------------------------------------------|
| time         | The datetime in ISO-8601 format                                                |
| pid          | Procedd ID                                                                     |
| host         | ENV['REMOTE_ADDR']                                                             |
| forwardedfor | ENV['X_FORWARDED_FOR']                                                         |
| user         | ENV['REMOTE_USER']                                                             |
| method       | ENV['REQUEST_METHOD']                                                          |
| uri          | ENV['PATH_INFO']                                                               |
| query        | ENV['QUERY_STRING']                                                            |
| protocol     | ENV['HTTP_VERSION']                                                            |
| status       | Response Status Code                                                           |
| size         | Response Content-Length                                                        |
| reqtime      | The request time in secods. milli seconds are written after the decimal point. |


## Arguments

Arguments:

* io
  * An IO object, or something which has `#write` method
* ~~appends (deprecated)~~
  * ~~A Hash object to append custom fields. See [#custom-fields](#custom-fields)~~

Keyword Arguments:

* params\_proc
  * A Proc object to generate fields. See [#custom-fields](#custom-fields)

### Log Rotation

If you utilize log rotation functionality of Ruby's standard logger, you may write as

```ruby
class MyLogger < ::Logger
  def write(msg)
    @logdev.write msg
  end
end

logger = MyLogger.new('/path/to/access.log', 3, 1048576)
config.middleware.insert_after(0, Rack::LtsvLogger, logger)
```

### Custom Fields

Pass a proc object to customize fields as:

```ruby
params_proc = Proc.new do |env, status, headers, body, began_at|
  params = Rack::LtsvLogger::DEFAULT_PARAMS_PROC.call(env, status, headers, body, began_at)
  params.delete(:protocol)
  params.merge!(
    vhost: env['HTTP_HOST'] || "-",
    ua: env['HTTP_USER_AGENT'] || "-",
    referer: env['HTTP_REFERER'] || "-",
  )
end
config.middleware.insert_after(0, Rack::LtsvLogger, $stdout, params_proc: params_proc)
```

or

```ruby
params_proc = Proc.new do |env, status, headers, body, began_at|
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
    status: ::Rack::LtsvLogger.extract_status(status),
    size: ::Rack::LtsvLogger.extract_content_length(headers),
    reqtime: "%0.6f" % reqtime,
    vhost: env['HTTP_HOST'] || "-",
    ua: env['HTTP_USER_AGENT'] || "-",
    referer: env['HTTP_REFERER'] || "-",
  }
end
config.middleware.insert_after(0, Rack::LtsvLogger, $stdout, params_proc: params_proc)
```

I recommend to follow http://ltsv.org/ to add new key names.

**Deprecated**

```ruby
appends = {
  vhost: Proc.new {|env| env['HTTP_HOST'] || "-" },
  ua: Proc.new {|env| env['HTTP_USER_AGENT'] || "-" },
  referer: Proc.new {|env| env['HTTP_REFERER'] || "-" },
}
config.middleware.insert_after(0, Rack::LtsvLogger, $stdout, appends)
```

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

See [LICENSE.txt](LICENSE.txt) for details.
