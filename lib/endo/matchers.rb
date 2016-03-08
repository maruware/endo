require 'endo/matchers/base_matcher'
require 'endo/matchers/eq'
require 'endo/matchers/include'


module Endo
  module Matchers
    def eq(expected)
      Matchers::Eq.new(expected)
    end

    def include(expected)
      Matchers::Include.new(expected)
    end
  end
end