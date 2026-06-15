# frozen_string_literal: true

require "test_helper"

class FormatTest < Minitest::Test
  EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

  def rule(regex: EMAIL_REGEX)
    CsvProcessor::Rules::Format.new(:email, regex: regex)
  end

  def errors_for(value, regex: EMAIL_REGEX)
    record  = { email: value }
    context = CsvProcessor::Context.new
    rule(regex: regex).call(record, context)
    context.errors
  end

  def test_matching_value_adds_no_errors
    assert_empty errors_for("user@example.com")
  end

  def test_non_matching_value_adds_error
    errors = errors_for("not-an-email")

    assert_equal 1, errors.size
    assert_equal :email, errors.first[:field]
    assert_equal "is invalid", errors.first[:message]
  end

  def test_nil_value_is_skipped
    assert_empty errors_for(nil)
  end

  def test_empty_string_is_skipped
    assert_empty errors_for("")
  end

  def test_whitespace_only_is_skipped
    assert_empty errors_for("   ")
  end

  def test_custom_regex_is_applied
    errors = errors_for("abc123", regex: /\A\d+\z/)

    assert_equal 1, errors.size
  end

  def test_custom_regex_passes_on_match
    assert_empty errors_for("12345", regex: /\A\d+\z/)
  end
end
