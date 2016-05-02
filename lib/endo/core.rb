require 'open-uri'
require 'json'
require 'net/http'
require 'colorize'

module Endo
  class Core
    include Endo::Matchers

    def initialize
      @responses = {}
    end

    def base_url(url)
      @base_url = url
    end

    def basic_auth(user, pass)
      @basic_auth = {
        user: user, pass: pass
      }
    end

    def get(endpoint, &block)
      request(endpoint, :get, &block)
    end

    def post(endpoint, &block)
      request(endpoint, :post, &block)
    end

    def delete(endpoint, &block)
      request(endpoint, :delete, &block)
    end

    def patch(endpoint, &block)
      request(endpoint, :patch, &block)
    end

    def put(endpoint, &block)
      request(endpoint, :put, &block)
    end

    # TODO: Limit scope
    def param(key, val = nil)
      raise ArgumentError, 'DupValue' unless !val.nil? ^ block_given?
      @params[key.to_s] = val ? val : yield
    end

    # TODO: Limit scope
    def from(method, endpoint, lmd = nil, &_block)
      key = build_response_key(method, endpoint)
      raise "NotFoundKey [#{key}]" unless @responses.key? key

      res = @responses[key]
      val = nil
      if !lmd.nil?
        val = res.instance_exec(&lmd)
      elsif block_given?
        val = yield res
      else
        raise ArgumentError, 'UndefinedBlock'
      end

      unless val.is_a?(String) || val.is_a?(Integer) || val.is_a?(Numeric)
        raise 'BadValueType'
      end

      val
    end

    private

    def request(endpoint, method, &block)
      begin
        res_obj, duration_ms = request_proc(endpoint, method, &block)
        message = "🍺 #{method.upcase} #{endpoint} [#{duration_ms}ms]"
      rescue Errno::ECONNREFUSED => e
        message = "💀 #{e.message}".red
        exit 1
      rescue Error::HttpError => e
        message = "💩 #{method.upcase} #{endpoint} [code: #{e.code}]".red
        exit 1
      rescue Error::ValidationError => e
        message = "👮 #{method.upcase} #{endpoint} [expected: \"#{e.expected}\" actual: \"#{e.actual}\"]".yellow
      ensure
        puts message
      end
    end

    def request_proc(endpoint, method, &_block)
      @params = {}
      @expects = []
      yield if block_given?

      endpoint = apply_params_to_pattern(endpoint, @params)
      url = @base_url + endpoint

      res, duration_ms = request_with_timer(url, method, @params)
      validate_expects(res) if @expects.any?

      res_obj = parse_body_json(res)
      @responses[build_response_key(method, endpoint)] = parse_body_json(res)

      [res_obj, duration_ms]
    end

    def request_with_timer(url, method, params)
      t_start = Time.now.instance_eval { to_i * 1000 + (usec / 1000) }
      res = http_request(url, params, method: method)
      t_end = Time.now.instance_eval { to_i * 1000 + (usec / 1000) }

      [res, t_end - t_start]
    end

    def http_request(url, params, method: :get)
      uri = URI.parse url
      req = create_request_each_method(uri, params, method)

      req.basic_auth @basic_auth[:user], @basic_auth[:pass] if @basic_auth

      res = Net::HTTP.start(uri.host, uri.port) { |http| http.request(req) }
      raise Error::HttpError.new("HTTP Bad Status[#{res.code}] #{res.body}", res.code, res.body) unless /^20[0-8]$/ =~ res.code

      res
    end

    def create_request_each_method(uri, params, method)
      case method
      when :get
        uri.query = URI.encode_www_form(params)
        Net::HTTP::Get.new uri
      when :post
        req = Net::HTTP::Post.new uri.path
        req.set_form_data(params)
        req
      when :delete
        uri.query = URI.encode_www_form(params)
        Net::HTTP::Delete.new uri
      when :patch
        uri.query = URI.encode_www_form(params)
        Net::HTTP::Patch.new uri
      when :put
        uri.query = URI.encode_www_form(params)
        Net::HTTP::Put.new uri
      end
    end

    def parse_body_json(res)
      JSON.parse(res.body, symbolize_names: true) if res.body
    end

    def build_response_key(method, endpoint)
      "#{method}:#{endpoint}"
    end

    def apply_params_to_pattern(endpoint, params)
      patterns = endpoint.scan(/:(\w+)/)
      if patterns.any?
        patterns.flatten!
        patterns.each do |pattern|
          raise "NotFoundPattern #{pattern}" unless params.key? pattern
          endpoint.sub!(/:#{pattern}/, params[pattern].to_s)
        end

        patterns.uniq.each do |pattern|
          params.delete(pattern)
        end
      end
      endpoint
    end

    def expect(header: nil, body: nil)
      unless !header.nil? ^ !body.nil?
        raise ArgumentError, '"expect" must be called with header or body'
      end

      if header
        expectation = ExpectationTarget.new(:header, header)
      elsif body
        expectation = ExpectationTarget.new(:body, body)
      end
      @expects << expectation
      expectation
    end

    def validate_expects(res)
      @expects.each do |expectation|
        unless expectation.matches?(res)
          raise Error::ValidationError.new(expectation.expected, expectation.actual)
        end
      end
    end
  end
end
