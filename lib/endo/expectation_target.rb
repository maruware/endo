module Endo
  class ExpectationTarget
    attr_reader :actual

    def initialize(target, query)
      @target = target
      @query = query
    end

    def to(matcher)
      @matcher = matcher
    end

    def matches?(res)
      @actual = case @target
      when :header
        res.header[@query]
      when :body
        obj = JSON.parse res.body, symbolize_names: true
        obj.instance_exec(&@query)
      end
      @matcher.matches?(@actual)
    end


    def expected
      @matcher.expected
    end


  end
end