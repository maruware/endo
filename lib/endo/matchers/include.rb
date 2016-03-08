module Endo
  module Matchers
    class Include < BaseMatcher
      attr_reader :expected

      private
        def match(expected, actual)
          if actual.respond_to? :include?
            actual.include? expected
          else
            raise 'NotSupported'
          end
        end
    end
  end
end