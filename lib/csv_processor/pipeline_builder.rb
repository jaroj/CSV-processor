# frozen_string_literal: true

require_relative "pipeline"

module CSVProcessor
  class PipelineBuilder
    def initialize
      @rules      = []
      @seen_keys  = []
      @seen_procs = []
    end

    def transform(field_or_callable, klass = nil, **)
      if field_or_callable.respond_to?(:call)
        register_callable(field_or_callable)
      else
        raise ArgumentError, "a rule class must be provided as the second argument" if klass.nil?

        register_class_rule(field_or_callable, klass, **)
      end
    end

    alias validate transform

    def build
      Pipeline.new(@rules)
    end

    private

    def register_callable(callable)
      if @seen_procs.any? { |p| p.equal?(callable) }
        raise ArgumentError, "duplicate rule: #{callable.inspect} is already registered"
      end

      @seen_procs << callable
      @rules << callable
    end

    def register_class_rule(field, klass, **)
      key = [field, klass]
      raise ArgumentError, "duplicate rule: #{klass} on :#{field} is already registered" if @seen_keys.include?(key)

      @seen_keys << key
      @rules << klass.new(field, **)
    end
  end
end
