
module Endo
  module Error
    class ValidationError < StandardError
      attr_reader :expected, :actual

      def initialize(expected, actual)
        super("expected: #{expected}\n actual: #{actual}")
        @expected = expected
        @actual = actual
      end

    end
  end
end