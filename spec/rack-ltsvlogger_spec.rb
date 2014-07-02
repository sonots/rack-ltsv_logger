require_relative 'spec_helper'
require 'fileutils'

describe Rack::LtsvLogger do
  app = lambda { |env|
    [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]]
  }

  let(:log_dir)  { "#{File.dirname(__FILE__)}/log" }
  let(:now)      { Time.now }
  let(:time)     { now.iso8601 }
  let(:pid)      { Process.pid }
  let(:host)     { '127.0.0.1' }
  let(:vhost)    { '127.0.0.1:80' }
  let(:forwardedfor) { '127.0.0.2' }
  let(:ua)       { 'mock' }
  let(:referer)  { 'http://example.com' }
  let(:env) do
    {
      'REMOTE_ADDR' => host,
      'HTTP_HOST' => vhost,
      'HTTP_X_FORWARDED_FOR' => forwardedfor,
      'HTTP_USER_AGENT' => ua,
      'HTTP_REFERER' => referer,
    }
  end

  def parse_ltsv(ltsv)
    Hash[*(ltsv.chomp.split("\t").map {|e| e.split(":", 2) }.flatten)]
  end

  def ltsv(hash)
    hash.map {|k, v| "#{k}:#{v}" }.join("\t") + "\n"
  end

  before do
    Dir.mkdir log_dir
    Timecop.freeze now
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

    context 'GET /get?foo' do
      let(:method) { 'GET' }
      let(:uri)    { '/get' }
      it do
        Rack::MockRequest.new(subject).get('/get?foo', env)
        expect(@test_io.string).to eq \
          "time:#{time}\tpid:#{pid}\thost:#{host}\tvhost:#{vhost}\tforwardedfor:#{forwardedfor}\t" +
          "size:-\tstatus:200\tmethod:#{method}\turi:#{uri}\tua:#{ua}\treferer:#{referer}\treqtime:0.0\n"
      end
    end

    context 'POST /post' do
      let(:method) { 'POST' }
      let(:uri)    { '/post' }
      it do
        Rack::MockRequest.new(subject).post('/post', env)
        expect(@test_io.string).to eq \
          "time:#{time}\tpid:#{pid}\thost:#{host}\tvhost:#{vhost}\tforwardedfor:#{forwardedfor}\t" +
          "size:-\tstatus:200\tmethod:#{method}\turi:#{uri}\tua:#{ua}\treferer:#{referer}\treqtime:0.0\n"
      end
    end
  end

  context 'append fields' do
    let(:appends) do
      { x_runtime: Proc.new {|env| '1.234' } }
    end

    subject do
      @test_io = StringIO.new
      Rack::Lint.new( Rack::LtsvLogger.new(app, @test_io, appends) )
    end

    it 'GET /get' do
      Rack::MockRequest.new(subject).get('/get', env)
      params = parse_ltsv(@test_io.string)
      expect(params['x_runtime']).to eq('1.234')
    end
  end
end
