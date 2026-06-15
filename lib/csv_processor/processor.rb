# frozen_string_literal: true

require "csv"

module CSVProcessor
  class Processor
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def call(path)
      CSV.foreach(path, headers: true).map.with_index(1) do |row, index|
        @pipeline.call(row.to_h.transform_keys(&:to_sym), row: index)
      end
    end
  end
end
