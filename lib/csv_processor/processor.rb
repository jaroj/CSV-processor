# frozen_string_literal: true

require "csv"

module CsvProcessor
  class Processor
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def call(path)
      CSV.foreach(path, headers: true).map do |row|
        @pipeline.call(row.to_h.transform_keys(&:to_sym))
      end
    end
  end
end
