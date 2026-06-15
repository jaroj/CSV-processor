# frozen_string_literal: true

require_relative "../rule"

module CsvProcessor
  module Rules
    class NormalizeEmail
      include CsvProcessor::Rule

      def initialize(field, **_opts)
        @field = field
      end

      def call(record, _context)
        value = record[@field]
        record[@field] = value.strip.downcase if value.respond_to?(:strip)
      end
    end
  end
end
