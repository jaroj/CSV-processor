# frozen_string_literal: true

require "test_helper"

class ContextTest < Minitest::Test
  def setup
    @context = CSVProcessor::Context.new
  end

  def test_errors_starts_empty
    assert_empty @context.errors
  end

  def test_add_error_appends_a_hash
    @context.add_error(:email, "is invalid")

    assert_equal 1, @context.errors.size
    assert_equal :email, @context.errors.first[:field]
    assert_equal "is invalid", @context.errors.first[:message]
  end

  def test_symbol_field_is_preserved
    @context.add_error(:name, "must be present")

    assert_equal :name, @context.errors.first[:field]
  end

  def test_string_field_is_coerced_to_symbol
    @context.add_error("email", "is invalid")

    assert_equal :email, @context.errors.first[:field]
  end

  def test_multiple_errors_accumulate
    @context.add_error(:email, "must be present")
    @context.add_error(:name, "is invalid")

    assert_equal 2, @context.errors.size
  end
end
