require 'endo/matchers/base_matcher'
require 'endo/matchers/eq'


module Endo
  module Matchers
    def eq(expected)
      Matchers::Eq.new(expected)
    end
  end
end