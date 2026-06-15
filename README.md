# CsvProcessor

A Ruby library for processing CSV records through a configurable pipeline of rules. Rules either transform field values or validate them. The pipeline collects **all** errors instead of stopping on the first failure.

## Requirements

Ruby 3.3 or higher.

## Installation

Add to your Gemfile:

```ruby
gem "csv_processor"
```

Then run:

```sh
bundle install
```

Or install directly:

```sh
gem install csv_processor
```

## Quick start

```ruby
require "csv_processor"

pipeline = CsvProcessor.define do
  transform :email, CsvProcessor::Rules::NormalizeEmail
  transform :name,  CsvProcessor::Rules::DefaultValue, default: "unknown"
  validate  :email, CsvProcessor::Rules::Presence
  validate  :email, CsvProcessor::Rules::Format, regex: URI::MailTo::EMAIL_REGEXP
end

results = CsvProcessor::Processor.new(pipeline).call("users.csv")

results.each do |result|
  if result.valid?
    puts "OK: #{result.record}"
  else
    puts "ERRORS: #{result.errors}"
  end
end
```

## Usage

### The `define` DSL

`CsvProcessor.define` builds a pipeline inside a block. `transform` and `validate` are interchangeable — both register a rule. The distinction is semantic, to make pipelines readable.

```ruby
pipeline = CsvProcessor.define do
  transform :email, CsvProcessor::Rules::NormalizeEmail
  validate  :email, CsvProcessor::Rules::Presence
end
```

### Three ways to define a rule

**1. Class-based rule (recommended for reuse)**

```ruby
pipeline = CsvProcessor.define do
  transform :email, CsvProcessor::Rules::NormalizeEmail
  validate  :email, CsvProcessor::Rules::Format, regex: /\A[^@]+@[^@]+\z/
end
```

**2. Lambda — for quick, inline logic**

```ruby
strip_phone = ->(record, _ctx) { record[:phone] = record[:phone].to_s.gsub(/\D/, "") }

pipeline = CsvProcessor.define do
  transform :email, CsvProcessor::Rules::NormalizeEmail
  transform strip_phone
end
```

Lambdas can sit alongside class-based rules in the same `define` block.

**3. `Pipeline.new` directly — no DSL**

```ruby
pipeline = CsvProcessor::Pipeline.new([
  CsvProcessor::Rules::NormalizeEmail.new(:email),
  CsvProcessor::Rules::Presence.new(:email),
  ->(record, ctx) { ctx.add_error(:age, "must be positive") if record[:age].to_i < 1 }
])
```

### Processing a CSV file

```ruby
results = CsvProcessor::Processor.new(pipeline).call("path/to/file.csv")
```

`Processor#call` returns an array of `Result` objects, one per CSV row.

### Working with results

```ruby
result.valid?              # => true / false
result.invalid?            # => true / false
result.record              # => { email: "user@example.com", ... }  (transformed)
result.original            # => { email: "USER@EXAMPLE.COM", ... }  (original CSV row)
result.row                 # => 1  (1-based data row index, nil when called outside Processor)
result.errors              # => [{ field: :email, message: "is invalid" }, ...]
result.errors_for(:email)  # => [{ field: :email, message: "is invalid" }]
```

### Built-in rules

| Rule | Type | Options |
|---|---|---|
| `NormalizeEmail` | transform | — |
| `DefaultValue` | transform | `default:` (required) |
| `Presence` | validate | — |
| `Format` | validate | `regex:` (required) |

## Adding custom rules

Any object that responds to `call(record, context)` is a valid rule — no base class required.

```ruby
class ValidateAge
  def initialize(field, min:, max:)
    @field = field
    @min   = min
    @max   = max
  end

  def call(record, context)
    age = record[@field].to_i
    return if age.between?(@min, @max)

    context.add_error(@field, "must be between #{@min} and #{@max}")
  end
end

pipeline = CsvProcessor.define do
  validate :age, ValidateAge, min: 18, max: 99
end
```

Optionally include `CsvProcessor::Rule` for the `blank?` helper:

```ruby
class SanitizePhone
  include CsvProcessor::Rule

  def initialize(field, **_opts)
    @field = field
  end

  def call(record, _context)
    return if blank?(record[@field])

    record[@field] = record[@field].gsub(/\D/, "")
  end
end
```

## Design decisions

**Uniform call interface.** Every rule — built-in or custom — implements `call(record, context)`. There is no base class requirement. A lambda, a plain class, or a class that includes the optional `CsvProcessor::Rule` mixin are all first-class rules. This follows duck typing: if it responds to `call`, it works.

**Immutable record flow.** `Pipeline` duplicates the incoming record before passing it through rules (`record.dup`). The `Result` object exposes both `record` (post-processing) and `original` (the unmodified input). Rules should assign new values to fields rather than mutating strings in-place to preserve this guarantee (e.g. `value.strip.downcase` not `value.strip!`).

**`transform` and `validate` are the same method.** In `PipelineBuilder`, `validate` is an alias for `transform`. Both register a rule object — the distinction is documentary only. This keeps the pipeline interface minimal while making the intent of each rule clear to readers.

**Format skips blank values.** `Format` returns early if the field is nil or blank. A blank field is the concern of `Presence`. Running both rules on the same field will produce at most one error: either "must be present" or "is invalid", never both.

**DSL detects callables automatically.** `transform` checks whether the first argument responds to `call`. If it does, the argument is used directly as a rule (lambda path). If not, it is treated as a class and instantiated with `klass.new(field, **opts)`. This allows mixing both styles in a single `define` block.

## Development

```sh
bin/setup       # install dependencies
bin/console     # interactive console
bundle exec rake          # run tests + RuboCop
bundle exec rake test     # tests only
bundle exec rubocop       # lint only
```

## Sample CSV

`fixtures/sample.csv` contains four rows designed to exercise all built-in rules:

| name | email | phone |
|---|---|---|
| Alice | ALICE@EXAMPLE.COM | +1 (555) 000-1234 |
| Bob | _(blank)_ | 5550001235 |
| _(blank)_ | valid@example.com | 5550001236 |
| Charlie | not-an-email | 5550001237 |

- Alice: valid after normalization
- Bob: fails `Presence` on email
- Row 3: name gets `DefaultValue` applied
- Charlie: fails `Format` on email

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
