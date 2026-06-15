# frozen_string_literal: true

require "test_helper"
require "uri"

class ProcessorTest < Minitest::Test
  FIXTURE_PATH = File.expand_path("../fixtures/sample.csv", __dir__)

  EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

  def pipeline
    CSVProcessor.define do
      transform :email, CSVProcessor::Rules::NormalizeEmail
      transform :name,  CSVProcessor::Rules::DefaultValue, default: "unknown"
      validate  :email, CSVProcessor::Rules::Presence
      validate  :email, CSVProcessor::Rules::Format, regex: EMAIL_REGEX
    end
  end

  def results
    @results ||= CSVProcessor::Processor.new(pipeline).call(FIXTURE_PATH)
  end

  def test_returns_one_result_per_row
    assert_equal 4, results.size
  end

  def test_alice_email_is_normalized
    assert_equal "alice@example.com", results[0].record[:email]
  end

  def test_alice_row_is_valid
    assert results[0].valid?
  end

  def test_bob_row_is_invalid_missing_email
    refute results[1].valid?
    assert_equal 1, results[1].errors_for(:email).size
    assert_equal "must be present", results[1].errors_for(:email).first[:message]
  end

  def test_blank_name_gets_default_value
    assert_equal "unknown", results[2].record[:name]
  end

  def test_third_row_is_valid
    assert results[2].valid?
  end

  def test_charlie_email_fails_format_validation
    refute results[3].valid?
    assert_equal 1, results[3].errors_for(:email).size
    assert_equal "is invalid", results[3].errors_for(:email).first[:message]
  end

  def test_original_record_is_unmodified
    assert_equal "ALICE@EXAMPLE.COM", results[0].original[:email]
  end

  def test_row_numbers_are_1_based
    results.each_with_index do |result, i|
      assert_equal i + 1, result.row
    end
  end

  def test_empty_csv_returns_empty_array
    Tempfile.create(["empty", ".csv"]) do |f|
      f.write("name,email,phone\n")
      f.flush
      result = CSVProcessor::Processor.new(pipeline).call(f.path)
      assert_empty result
    end
  end
end
