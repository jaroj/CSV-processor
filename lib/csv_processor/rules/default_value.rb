# frozen_string_literal: true

require_relative "../rule"

module CSVProcessor
  module Rules
    class DefaultValue
      include CSVProcessor::Rule

      def initialize(field, default:, **_opts)
        @field   = field
        @default = default
      end

      def call(record, _context)
        record[@field] = @default if blank?(record[@field])
      end
    end
  end
end
