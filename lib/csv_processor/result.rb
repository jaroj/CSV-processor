# frozen_string_literal: true

module CSVProcessor
  class Result
    attr_reader :record, :original, :errors, :row

    def initialize(record:, original:, errors:, row: nil)
      @record   = record
      @original = original
      @errors   = errors
      @row      = row
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
