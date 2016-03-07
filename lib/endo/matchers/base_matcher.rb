module Endo
  module Matchers
    class BaseMatcher
      attr_reader :expected

      def initialize(expected)
        @expected = expected
      end

      def matches?(actual)
        match(expected, actual)
      end
    end
  end
end