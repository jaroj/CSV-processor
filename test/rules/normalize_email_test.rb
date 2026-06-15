# frozen_string_literal: true

require "test_helper"

class NormalizeEmailTest < Minitest::Test
  def rule
    CsvProcessor::Rules::NormalizeEmail.new(:email)
  end

  def call(value)
    record = { email: value }
    rule.call(record, CsvProcessor::Context.new)
    record[:email]
  end

  def test_strips_leading_whitespace
    assert_equal "user@example.com", call("  user@example.com")
  end

  def test_strips_trailing_whitespace
    assert_equal "user@example.com", call("user@example.com  ")
  end

  def test_downcases_value
    assert_equal "user@example.com", call("USER@EXAMPLE.COM")
  end

  def test_strips_and_downcases_together
    assert_equal "user@example.com", call("  USER@EXAMPLE.COM  ")
  end

  def test_nil_value_is_left_unchanged
    assert_nil call(nil)
  end

  def test_already_normalized_value_is_unchanged
    assert_equal "user@example.com", call("user@example.com")
  end

  def test_does_not_add_errors
    record  = { email: "  USER@EXAMPLE.COM  " }
    context = CsvProcessor::Context.new
    rule.call(record, context)

    assert_empty context.errors
  end

  def test_field_absent_from_record_is_a_noop
    record  = {}
    context = CsvProcessor::Context.new
    rule.call(record, context)

    assert_empty record
    assert_empty context.errors
  end
end
