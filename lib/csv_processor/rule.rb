# frozen_string_literal: true

module CsvProcessor
  module Rule
    def blank?(value)
      value.nil? || (value.respond_to?(:strip) && value.strip.empty?)
    end
  end
end
