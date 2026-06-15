# frozen_string_literal: true

require_relative "context"
require_relative "result"

module CSVProcessor
  class Pipeline
    def initialize(rules)
      @rules = rules
    end

    def call(record, row: nil)
      context = Context.new
      processed = record.dup
      @rules.each { |rule| rule.call(processed, context) }
      Result.new(record: processed, original: record, errors: context.errors, row: row)
    end
  end
end
