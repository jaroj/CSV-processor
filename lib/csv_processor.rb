# frozen_string_literal: true

require_relative "csv_processor/version"
require_relative "csv_processor/context"
require_relative "csv_processor/result"
require_relative "csv_processor/rule"
require_relative "csv_processor/pipeline"
require_relative "csv_processor/pipeline_builder"
require_relative "csv_processor/processor"
require_relative "csv_processor/rules/normalize_email"
require_relative "csv_processor/rules/default_value"
require_relative "csv_processor/rules/presence"
require_relative "csv_processor/rules/format"

module CsvProcessor
  class Error < StandardError; end

  def self.define(&block)
    builder = PipelineBuilder.new
    builder.instance_eval(&block)
    builder.build
  end
end
