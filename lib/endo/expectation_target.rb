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
      case @target
      when :header
        @actual = res.header[@query]
      when :body
        obj = JSON.parse res.body
        @actual = if @query.is_a? Proc
                    obj.instance_exec(&@query)
                  else
                    obj[@query]
                  end
      end
      @matcher.matches?(@actual)
    end

    def expected
      @matcher.expected
    end
  end
end
