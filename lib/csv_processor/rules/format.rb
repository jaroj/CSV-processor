# frozen_string_literal: true

require_relative "../rule"

module CSVProcessor
  module Rules
    class Format
      include CSVProcessor::Rule

      def initialize(field, regex:, **_opts)
        @field = field
        @regex = regex
      end

      def call(record, context)
        value = record[@field]
        return if blank?(value)

        context.add_error(@field, "is invalid") unless value.to_s.match?(@regex)
      end
    end
  end
end
