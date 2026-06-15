# frozen_string_literal: true

require_relative "../rule"

module CsvProcessor
  module Rules
    class Presence
      include CsvProcessor::Rule

      def initialize(field, **_opts)
        @field = field
      end

      def call(record, context)
        context.add_error(@field, "must be present") if blank?(record[@field])
      end
    end
  end
end
