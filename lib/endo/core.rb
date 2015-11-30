require 'open-uri'
require 'json'
require 'net/http'

module Endo
  class Core
    def initialize
      @props = {}
      @responses = {}
    end

    def set(key, val)
      #TODO: validate key
      @props[key] = val
    end

    def get(endpoint, &block)
      request(endpoint, :get, &block)
    end

    def post(endpoint, &block)
      request(endpoint, :post, &block)
    end

    #TODO: 制限
    def param(key, val=nil, &block)
      unless (!val.nil?) ^ (!block.nil?) # Only either one
        raise ArgumentError.new('DupValue')
      end

      @params[key.to_s] = if val
        val
      else
        block.call
      end

    end

    #TODO: Limit scope
    def from(method, endpoint, lmd=nil, &block)
      key = build_response_key(method, endpoint)
      unless @responses.has_key? key
        raise RuntimeError.new("NotFoundKey [#{key}]")
      end

      res = @responses[key]
      val = if lmd
        res.instance_exec &lmd
      elsif block
        block.call(res)
      else
        raise ArgumentError.new('UndefinedBlock')
      end

      unless val.is_a?(String) || val.is_a?(Integer) || val.is_a?(Numeric)
        raise RuntimeError.new('BadValueType')
      end

      val
    end

    private
    def request(endpoint, method, &block)
      org_endpoint = endpoint.clone

      @params = {}
      block.call if block

      endpoint = apply_pattern_vars(endpoint, @params)

      url = @props[:base_url] + endpoint

      message = begin
        t_start = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
        res = http_request_json(url, @params, method: method)
        t_end = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }

        @responses[build_response_key(method, endpoint)] = res
        "🍺 #{endpoint} [#{t_end-t_start}ms]"
      rescue Error::HttpError=>e
        "💩 #{endpoint} [code: #{e.code}]"
      end


      puts message
    end

    def apply_pattern_vars(endpoint, params)
      patterns = endpoint.scan(/:(\w+)/)
      if patterns.any?
        patterns.flatten!
        patterns.each do |pattern|
          unless params.has_key? pattern
            raise RuntimeError.new("NotFoundPattern #{pattern}")
          end

          endpoint.sub!(/:#{pattern}/, params[pattern].to_s)
        end

        patterns.uniq.each do |pattern|
          params.delete(pattern)
        end
      end
      endpoint
    end

    def http_request_json(url, params, method: :get, symbolize_names: true)
      res = http_request(url, params, method)
      JSON.parse(res, symbolize_names: symbolize_names)
    end

    def http_request(url, params, method)
      uri = URI.parse url

      if method == :get
        uri.query = URI.encode_www_form(params)
        req = Net::HTTP::Get.new uri
      end

      if method == :post
        req = Net::HTTP::Post.new uri.path
        req.set_form_data(params)
      end

      res = Net::HTTP.start(uri.host, uri.port) {|http| http.request req }
      raise Error::HttpError.new("HTTP Bad Status[#{res.code}] #{res.body}", res.code, res.body) unless /^20[0-8]$/ =~ res.code

      return res.body
    end

    def build_response_key(method, endpoint)
      "#{method}:#{endpoint}"
    end

  end
end