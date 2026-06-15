# frozen_string_literal: true

require "test_helper"

class ResultTest < Minitest::Test
  def test_valid_when_no_errors
    result = CsvProcessor::Result.new(record: {}, original: {}, errors: [])

    assert result.valid?
    refute result.invalid?
  end

  def test_invalid_when_errors_present
    result = CsvProcessor::Result.new(
      record: {},
      original: {},
      errors: [{ field: :email, message: "is invalid" }]
    )

    assert result.invalid?
    refute result.valid?
  end

  def test_errors_for_filters_by_field_symbol
    errors = [
      { field: :email, message: "is invalid" },
      { field: :name,  message: "must be present" }
    ]
    result = CsvProcessor::Result.new(record: {}, original: {}, errors: errors)

    assert_equal 1, result.errors_for(:email).size
    assert_equal "is invalid", result.errors_for(:email).first[:message]
  end

  def test_errors_for_accepts_string_field
    errors = [{ field: :email, message: "is invalid" }]
    result = CsvProcessor::Result.new(record: {}, original: {}, errors: errors)

    assert_equal 1, result.errors_for("email").size
  end

  def test_errors_for_returns_empty_when_no_match
    result = CsvProcessor::Result.new(record: {}, original: {}, errors: [])

    assert_empty result.errors_for(:email)
  end

  def test_record_and_original_are_accessible
    record   = { email: "user@example.com" }
    original = { email: "USER@EXAMPLE.COM" }
    result   = CsvProcessor::Result.new(record: record, original: original, errors: [])

    assert_equal record,   result.record
    assert_equal original, result.original
  end

  def test_row_defaults_to_nil
    result = CsvProcessor::Result.new(record: {}, original: {}, errors: [])

    assert_nil result.row
  end

  def test_row_is_accessible_when_provided
    result = CsvProcessor::Result.new(record: {}, original: {}, errors: [], row: 3)

    assert_equal 3, result.row
  end
end
