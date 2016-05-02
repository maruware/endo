require 'open-uri'
require 'json'
require 'net/http'
require 'colorize'

module Endo
  class Core
    include Endo::Matchers

    def initialize
      @props = {}
      @responses = {}
      @expect_alls = {}
    end

    def set(key, val)
      # TODO: validate key
      @props[key] = val
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

    # TODO: 制限
    def param(key, val = nil)
      raise ArgumentError, 'DupValue' unless !val.nil? ^ block_given?

      @params[key.to_s] = val ? val : yield
    end

    # TODO: Limit scope
    def from(method, endpoint, lmd = nil, &_block)
      key = build_response_key(method, endpoint)
      raise RuntimeError "NotFoundKey [#{key}]" unless @responses.key? key

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

    def basic_auth(user, pass)
      @basic_auth = {
        user: user, pass: pass
      }
    end

    private

    def request(endpoint, method, &_block)

      @params = {}
      @expects = []
      yield if block_given?

      endpoint = apply_pattern_vars(endpoint, @params)

      url = @props[:base_url] + endpoint

      begin
        t_start = Time.now.instance_eval { to_i * 1000 + (usec / 1000) }
        res = http_request(url, @params, method: method)
        t_end = Time.now.instance_eval { to_i * 1000 + (usec / 1000) }

        res_data = parse_body_json(res)
        @responses[build_response_key(method, endpoint)] = res_data
        validate_expects(res) unless @expect_alls.empty? && @expects.empty?
        message = "🍺 #{method.upcase} #{endpoint} [#{t_end - t_start}ms]"
      rescue Error::HttpError => e
        message = "💩 #{method.upcase} #{endpoint} [code: #{e.code}]".red
        exit 1
      rescue Error::ValidationError => e
        message = "👮 #{method.upcase} #{endpoint} [expected: \"#{e.expected}\" actual: \"#{e.actual}\"]".yellow
      ensure
        puts message
      end
    end

    def apply_pattern_vars(endpoint, params)
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

    def http_request(url, params, method: :get)
      uri = URI.parse url

      case method
      when :get
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Get.new uri
      when :post
        req = Net::HTTP::Post.new uri.path
        req.set_form_data(params)
        req
      when :delete
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Delete.new uri
      when :patch
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Patch.new uri
      when :put
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Put.new uri
      end

      if @basic_auth
        req.basic_auth @basic_auth[:user], @basic_auth[:pass]
      end

      res = Net::HTTP.start(uri.host, uri.port) { |http| http.request req }
      raise Error::HttpError.new("HTTP Bad Status[#{res.code}] #{res.body}", res.code, res.body) unless /^20[0-8]$/ =~ res.code

      res
    end

    def parse_body_json(res)
      JSON.parse(res.body, symbolize_names: true) if res.body
    end

    def build_response_key(method, endpoint)
      "#{method}:#{endpoint}"
    end

    def expect(header: nil, body: nil)
      if header
        expectation = ExpectationTarget.new(:header, header)
      elsif body
        expectation = ExpectationTarget.new(:body, body)
      else
        raise 'TODO'
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
