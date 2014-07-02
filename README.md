# Rack::LtsvLogger

A rack middleware to output access log in ltsv format, like [rack/commonlogger](https://github.com/rack/rack/blob/master/lib/rack/commonlogger.rb) (which output access log in apache common format).

## Why Rack Middleware

cf. https://speakerdeck.com/mirakui/high-performance-rails-long-edition

<img src="doc/x_runtime.png" alt="x_runtime" width="50%" height="50%"/>

The Completed Time does not include routing time, and elapsed time on rack middleware layers, and so on.
To measure the processing time accurately, it is necessary to insert a rack middleware to measure the time. 

## Installation

Add this line to your application's Gemfile:

    gem 'pfsys-rack-access_log'

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

```
time:#{time}\tpid:#{pid}\thost:#{ip}size:#{size}\tstatus:#{status}\tmethod:#{method}\turi:#{uri}\treqtime#{reqtime}
```

Sample:

```
time:2014-07-01T00:00:00+0900\tpid:1\thost:127.0.0.1\size:10\tstatus:200\tmethod:GET\turi:/api/token\treqtime:0.034617
```

### Fields

* time

  * The datetime in ISO-8601 format

* reqtime

  * The request time in secods. milli seconds are written after the decimal point. 

* Others

  * See http://ltsv.org/

## ToDo

* Make it possible to add fields

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
