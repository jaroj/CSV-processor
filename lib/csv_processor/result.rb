# frozen_string_literal: true

module CsvProcessor
  class Result
    attr_reader :record, :original, :errors

    def initialize(record:, original:, errors:)
      @record   = record
      @original = original
      @errors   = errors
    end

    def valid?
      errors.empty?
    end

    def invalid?
      !valid?
    end

    def errors_for(field)
      errors.select { |e| e[:field] == field.to_sym }
    end
  end
end
