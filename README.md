# Rack::LtsvLogger

A rack middleware to output access log in ltsv format, like [rack/commonlogger](https://github.com/rack/rack/blob/master/lib/rack/commonlogger.rb) (which output access log in apache common format).

## Why Rack Middleware

cf. https://speakerdeck.com/mirakui/high-performance-rails-long-edition

<img src="doc/x_runtime.png" alt="x_runtime" width="50%" height="50%"/>

The Completed Time does not include routing time, and elapsed time on rack middleware layers, and so on.
To measure the processing time accurately, it is necessary to insert a rack middleware to measure the time. 

## Installation

Add this line to your application's Gemfile:

    gem 'rack-ltsvlogger'

And then execute:

    $ bundle

## How to Use

Insert Rack::LtsvLogger on the head of rack middlewares. 

Rails)

Add following to config/environments/[env].rb

```ruby
require 'rack/ltsvlogger'
require 'logger'

config.middleware.insert_after(0, Rack::LtsvLogger, $stdout)
```

Sinatra)

```ruby
# config.ru
require 'rack/ltsvlogger'

use Rack::LtsvLogger, $stdout
run App
```

## Format

Sample (line feeded):

```
time:2014-07-01T00:00:00+0900\tpid:1\thost:127.0.0.1\tvhost:127.0.0.1:80\tforwardedfor:127.0.0.2\t
size:-\tstatus:200\tmethod:POST\turi:/post\tua:mock\treferer:http://example.com\treqtime:0.0\n
```

### Default Fields

* time

  * The datetime in ISO-8601 format

* pid

  * Process ID

* host

  * ENV['REMOTE_ADDR']

* vhost

  * ENV['HOST']

* forwardedfor

  * ENV['X_FORWARDED_FOR']

* size

  * Response Content-Length

* status

  * Response Status Code

* method

  * ENV['REQUEST_METHOD']

* uri

  * ENV['PATH_INFO']

* ua

  * ENV['USER_AGENT']

* referer

  * ENV['REFERER']

* reqtime

  * The request time in secods. milli seconds are written after the decimal point. 

* Others

  * See http://ltsv.org/

### Custom Fields

You may append LTSV fields as:

```ruby
appends = {
  vhost: Proc.new {|env| env['HTTP_HOST'] || '-' },
  forwardedfor: Proc.new {|env| env['HTTP_X_FORWARDED_FOR'] || '-' }
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
