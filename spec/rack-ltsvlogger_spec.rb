require_relative 'spec_helper'
require 'fileutils'

describe Rack::LtsvLogger do
  app = lambda { |env|
    [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
  }

  let(:log_dir)  { "#{File.dirname(__FILE__)}/log" }
  let(:now)      { Time.now.iso8601 }
  let(:host_ip)  { Socket.getaddrinfo(Socket::gethostname, nil, Socket::AF_INET)[0][3] }
  let(:pid)      { Process.pid }

  before do
    Dir.mkdir log_dir
    Timecop.freeze Time.now
  end

  after do
    FileUtils.rm_rf log_dir
    Timecop.return
  end

  context 'conform to Rack::Lint' do
    subject do
      @test_io = StringIO.new
      Rack::Lint.new( Rack::LtsvLogger.new(app, @test_io) )
    end

    let(:env) do
      {
        'REMOTE_ADDR' => '127.0.0.1',
        'HTTP_HOST' => '127.0.0.1:80',
        'HTTP_X_FORWARDED_FOR' => '127.0.0.2',
        'HTTP_USER_AGENT' => 'mock',
        'HTTP_REFERER' => 'http://example.com',
      }
    end

    it 'GET /get?foo' do
      Rack::MockRequest.new(subject).get('/get?foo', env)
      expect(@test_io.string).to eq "time:#{now}\tpid:#{pid}\thost:127.0.0.1\tvhost:127.0.0.1:80\tforwardedfor:127.0.0.2" +
        "\tsize:-\tstatus:200\tmethod:GET\turi:/get\tua:mock\treferer:http://example.com\treqtime:0.0\n"
    end

    it 'POST /post' do
      Rack::MockRequest.new(subject).post('/post', env)
      expect(@test_io.string).to eq "time:#{now}\tpid:#{pid}\thost:127.0.0.1\tvhost:127.0.0.1:80\tforwardedfor:127.0.0.2" +
        "\tsize:-\tstatus:200\tmethod:POST\turi:/post\tua:mock\treferer:http://example.com\treqtime:0.0\n"
    end
  end
end

