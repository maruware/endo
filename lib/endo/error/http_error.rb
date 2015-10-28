
module Endo
  module Error
    class HttpError < StandardError
      attr_reader :code, :body

      def initialize(message, code, body)
        super(message)
        @code = code
        @body = body
      end

    end
  end
end