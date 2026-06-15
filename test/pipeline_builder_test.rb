# frozen_string_literal: true

require "test_helper"

class PipelineBuilderTest < Minitest::Test
  def test_build_returns_a_pipeline
    builder = CsvProcessor::PipelineBuilder.new
    assert_instance_of CsvProcessor::Pipeline, builder.build
  end

  def test_transform_with_class_registers_rule
    builder = CsvProcessor::PipelineBuilder.new
    builder.transform(:email, CsvProcessor::Rules::NormalizeEmail)
    pipeline = builder.build

    result = pipeline.call({ email: "USER@EXAMPLE.COM" })

    assert_equal "user@example.com", result.record[:email]
  end

  def test_transform_with_lambda_registers_it_directly
    called = false
    rule   = ->(_r, _c) { called = true }

    builder = CsvProcessor::PipelineBuilder.new
    builder.transform(rule)
    builder.build.call({})

    assert called
  end

  def test_validate_alias_works_like_transform
    builder = CsvProcessor::PipelineBuilder.new
    builder.validate(:email, CsvProcessor::Rules::Presence)
    result = builder.build.call({ email: nil })

    assert result.invalid?
  end

  def test_mix_of_class_and_lambda_rules
    pipeline = build_mixed_pipeline
    result   = pipeline.call({ email: "USER@EXAMPLE.COM", name: "alice" })

    assert_equal "user@example.com", result.record[:email]
    assert_equal "ALICE", result.record[:name]
    assert result.valid?
  end

  private

  def build_mixed_pipeline
    upcase = ->(record, _ctx) { record[:name] = record[:name].to_s.upcase }
    builder = CsvProcessor::PipelineBuilder.new
    builder.transform(:email, CsvProcessor::Rules::NormalizeEmail)
    builder.transform(upcase)
    builder.validate(:email, CsvProcessor::Rules::Presence)
    builder.build
  end

  def test_transform_with_symbol_and_no_class_raises
    builder = CsvProcessor::PipelineBuilder.new

    assert_raises(ArgumentError) { builder.transform(:email) }
  end

  def test_define_dsl_produces_same_result_as_builder
    pipeline = CsvProcessor.define do
      transform :email, CsvProcessor::Rules::NormalizeEmail
      validate  :email, CsvProcessor::Rules::Presence
    end

    result = pipeline.call({ email: "  HELLO@EXAMPLE.COM  " })

    assert_equal "hello@example.com", result.record[:email]
    assert result.valid?
  end
end
