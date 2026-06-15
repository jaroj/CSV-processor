# frozen_string_literal: true

require_relative "pipeline"

module CsvProcessor
  class PipelineBuilder
    def initialize
      @rules = []
    end

    def transform(field_or_callable, klass = nil, **)
      if field_or_callable.respond_to?(:call)
        @rules << field_or_callable
      else
        raise ArgumentError, "a rule class must be provided as the second argument" if klass.nil?

        @rules << klass.new(field_or_callable, **)
      end
    end

    alias validate transform

    def build
      Pipeline.new(@rules)
    end
  end
end
