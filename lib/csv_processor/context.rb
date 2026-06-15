# frozen_string_literal: true

module CsvProcessor
  class Context
    attr_reader :errors

    def initialize
      @errors = []
    end

    def add_error(field, message)
      @errors << { field: field.to_sym, message: message }
    end
  end
end
