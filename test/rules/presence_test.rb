# frozen_string_literal: true

require "test_helper"

class PresenceTest < Minitest::Test
  def rule
    CSVProcessor::Rules::Presence.new(:email)
  end

  def errors_for(value)
    record  = { email: value }
    context = CSVProcessor::Context.new
    rule.call(record, context)
    context.errors
  end

  def test_non_blank_value_adds_no_errors
    assert_empty errors_for("user@example.com")
  end

  def test_nil_value_adds_error
    errors = errors_for(nil)

    assert_equal 1, errors.size
    assert_equal :email, errors.first[:field]
    assert_equal "must be present", errors.first[:message]
  end

  def test_empty_string_adds_error
    assert_equal 1, errors_for("").size
  end

  def test_whitespace_only_string_adds_error
    assert_equal 1, errors_for("   ").size
  end

  def test_does_not_mutate_record
    record  = { email: nil }
    context = CSVProcessor::Context.new
    rule.call(record, context)

    assert_nil record[:email]
  end
end
