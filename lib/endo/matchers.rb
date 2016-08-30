require 'endo/matchers/base_matcher'
require 'endo/matchers/equal'
require 'endo/matchers/include'

module Endo
  module Matchers
    def equal(expected)
      Matchers::Equal.new(expected)
    end

    def include(expected)
      Matchers::Include.new(expected)
    end
  end
end
