require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    logger.info "OK"
  end
end
