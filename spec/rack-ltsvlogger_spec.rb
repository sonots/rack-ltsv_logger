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

    it 'GET /get?foo' do
      Rack::MockRequest.new(subject).get('/get?foo')
      expect(@test_io.string).to eq "time:#{now}\tpid:#{pid}\thost:#{host_ip}\tsize:17\tstatus:200\tmethod:GET\turi:/get\treqtime:0.0\n"
    end

    it 'POST /post' do
      Rack::MockRequest.new(subject).post('/post')
      expect(@test_io.string).to eq "time:#{now}\tpid:#{pid}\thost:#{host_ip}\tsize:17\tstatus:200\tmethod:POST\turi:/post\treqtime:0.0\n"
    end
  end
end

