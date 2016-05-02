module Endo
  module Matchers
    class Eq < BaseMatcher
      attr_reader :expected

      private

      def match(expected, actual)
        actual == expected
      end
    end
  end
end
