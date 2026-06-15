# frozen_string_literal: true

require_relative "context"
require_relative "result"

module CsvProcessor
  class Pipeline
    def initialize(rules)
      @rules = rules
    end

    def call(record)
      context = Context.new
      processed = record.dup
      @rules.each { |rule| rule.call(processed, context) }
      Result.new(record: processed, original: record, errors: context.errors)
    end
  end
end
