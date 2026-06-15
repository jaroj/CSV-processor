# frozen_string_literal: true

require "test_helper"

class DefaultValueTest < Minitest::Test
  def rule(default: "unknown")
    CsvProcessor::Rules::DefaultValue.new(:name, default: default)
  end

  def call(value, default: "unknown")
    record = { name: value }
    rule(default: default).call(record, CsvProcessor::Context.new)
    record[:name]
  end

  def test_nil_value_is_replaced_with_default
    assert_equal "unknown", call(nil)
  end

  def test_empty_string_is_replaced_with_default
    assert_equal "unknown", call("")
  end

  def test_whitespace_only_string_is_replaced_with_default
    assert_equal "unknown", call("   ")
  end

  def test_non_blank_value_is_left_unchanged
    assert_equal "Alice", call("Alice")
  end

  def test_custom_default_is_applied
    assert_equal "n/a", call(nil, default: "n/a")
  end

  def test_only_target_field_is_affected
    record = { name: nil, email: "user@example.com" }
    rule.call(record, CsvProcessor::Context.new)

    assert_equal "unknown",          record[:name]
    assert_equal "user@example.com", record[:email]
  end

  def test_does_not_add_errors
    record  = { name: nil }
    context = CsvProcessor::Context.new
    rule.call(record, context)

    assert_empty context.errors
  end
end
