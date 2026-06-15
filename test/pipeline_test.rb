# frozen_string_literal: true

require "test_helper"

class PipelineTest < Minitest::Test
  def test_returns_result
    pipeline = CsvProcessor::Pipeline.new([])
    result   = pipeline.call({ email: "user@example.com" })

    assert_instance_of CsvProcessor::Result, result
  end

  def test_valid_result_when_no_rules
    pipeline = CsvProcessor::Pipeline.new([])
    result   = pipeline.call({ email: "user@example.com" })

    assert result.valid?
  end

  def test_transform_rule_modifies_record_not_original
    rule = ->(record, _ctx) { record[:email] = record[:email].downcase }
    pipeline = CsvProcessor::Pipeline.new([rule])

    result = pipeline.call({ email: "USER@EXAMPLE.COM" })

    assert_equal "user@example.com", result.record[:email]
    assert_equal "USER@EXAMPLE.COM", result.original[:email]
  end

  def test_validation_rule_adds_errors
    rule = ->(record, ctx) { ctx.add_error(:email, "is invalid") if record[:email].nil? }
    pipeline = CsvProcessor::Pipeline.new([rule])

    result = pipeline.call({ email: nil })

    assert result.invalid?
    assert_equal 1, result.errors.size
  end

  def test_rules_run_in_order
    order = []
    rule_a = ->(_r, _c) { order << :a }
    rule_b = ->(_r, _c) { order << :b }
    rule_c = ->(_r, _c) { order << :c }

    CsvProcessor::Pipeline.new([rule_a, rule_b, rule_c]).call({})

    assert_equal %i[a b c], order
  end

  def test_multiple_rules_all_run_even_after_error
    result = CsvProcessor::Pipeline.new(two_error_rules).call({})

    assert_equal 2, result.errors.size
  end

  private

  def two_error_rules
    [
      ->(_r, ctx) { ctx.add_error(:email, "error a") },
      ->(_r, ctx) { ctx.add_error(:name, "error b") }
    ]
  end

  def test_class_based_rule_works
    rule     = CsvProcessor::Rules::NormalizeEmail.new(:email)
    pipeline = CsvProcessor::Pipeline.new([rule])

    result = pipeline.call({ email: "  USER@EXAMPLE.COM  " })

    assert_equal "user@example.com", result.record[:email]
  end

  def test_duplicate_rule_produces_duplicate_errors
    rule     = CsvProcessor::Rules::Presence.new(:email)
    pipeline = CsvProcessor::Pipeline.new([rule, rule])

    result = pipeline.call({ email: nil })

    assert_equal 2, result.errors.size
  end

  def test_transform_before_validate_prevents_presence_error
    default_rule  = CsvProcessor::Rules::DefaultValue.new(:email, default: "fallback@example.com")
    presence_rule = CsvProcessor::Rules::Presence.new(:email)
    pipeline      = CsvProcessor::Pipeline.new([default_rule, presence_rule])

    result = pipeline.call({ email: nil })

    assert result.valid?
    assert_equal "fallback@example.com", result.record[:email]
  end

  def test_validate_before_transform_still_errors_on_blank
    presence_rule = CsvProcessor::Rules::Presence.new(:email)
    default_rule  = CsvProcessor::Rules::DefaultValue.new(:email, default: "fallback@example.com")
    pipeline      = CsvProcessor::Pipeline.new([presence_rule, default_rule])

    result = pipeline.call({ email: nil })

    assert result.invalid?
    assert_equal "fallback@example.com", result.record[:email]
  end

  def test_rule_targeting_absent_field_sees_nil
    rule   = CsvProcessor::Rules::Presence.new(:missing)
    result = CsvProcessor::Pipeline.new([rule]).call({})

    assert result.invalid?
    assert_equal 1, result.errors_for(:missing).size
  end
end
