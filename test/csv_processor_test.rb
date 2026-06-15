# frozen_string_literal: true

require "test_helper"

class CsvProcessorTest < Minitest::Test
  def test_version_is_defined
    refute_nil CsvProcessor::VERSION
  end

  def test_define_returns_a_pipeline
    pipeline = CsvProcessor.define do
      transform :email, CsvProcessor::Rules::NormalizeEmail
    end

    assert_instance_of CsvProcessor::Pipeline, pipeline
  end

  def test_define_builds_a_working_pipeline
    pipeline = CsvProcessor.define do
      transform :email, CsvProcessor::Rules::NormalizeEmail
      validate  :email, CsvProcessor::Rules::Presence
    end

    result = pipeline.call({ email: "  USER@EXAMPLE.COM  " })

    assert result.valid?
    assert_equal "user@example.com", result.record[:email]
  end

  def test_define_accepts_lambda_alongside_class_rules
    upcase_name = ->(record, _ctx) { record[:name] = record[:name].to_s.upcase }

    pipeline = CsvProcessor.define do
      transform :email, CsvProcessor::Rules::NormalizeEmail
      transform upcase_name
    end

    result = pipeline.call({ email: "USER@EXAMPLE.COM", name: "alice" })

    assert_equal "user@example.com", result.record[:email]
    assert_equal "ALICE", result.record[:name]
  end
end
