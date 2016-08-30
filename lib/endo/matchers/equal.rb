module Endo
  module Matchers
    class Equal < BaseMatcher
      attr_reader :expected

      private

      def match(expected, actual)
        actual == expected
      end
    end
  end
end
