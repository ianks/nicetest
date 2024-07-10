# ☀️ nicetest

Enhance your minitest experience with nicetest—a gem offering a CLI, pretty
assertion diffs, pre-configured reporters, focus checks, and colorful backtrace
filters for seamless test running.

## Features

- A decent CLI for running tests, which is compatible with existing minitest plugin options
- Fancier diffs using [`super_diff`](https://github.com/mcmire/super_diff)
- Bundled [`minitest-reporters`](https://github.com/minitest-reporters/minitest-reporters), with defaults configured
- Bundled [`minitest-focus`](https://github.com/minitest/minitest-focus), with CI sanity check
- A pretty backtrace filter

## Usage

### Take it with you

`nicetest` runs well on most `minitest` suites without hassle, so you can just
use it wherever you happen to be:

```sh
# Gem install it
$ gem install nicetest

# Go into a repo
$ git clone https://github.com/Shopfy/liquid; cd liquid; bundle install

# Run the tests
$ nicetest --reporter doc test/integration/capture_test.rb
Started with run options --reporter doc --seed 12874

CaptureTest
  test_increment_assign_score_by_bytes_not_characters             PASS (0.00s)
  test_captures_block_content_in_variable                         PASS (0.00s)
  test_capture_to_variable_from_outer_scope_if_existing           PASS (0.00s)
  test_assigning_from_capture                                     PASS (0.00s)
  test_capture_with_hyphen_in_variable_name                       PASS (0.00s)

Finished in 0.00123s
5 tests, 5 assertions, 0 failures, 0 errors, 0 skips
```

### Add to project


Add to your `test_helper.rb`:

```ruby
# test/test_helper.rb

require "nicetest"

# whatever else you do... can probably remove some stuff
```

Then, make it easy to run:

```sh
# Add to Gemfile
$ bundle add nicetest

# Make a bin/test executable
$ bundle binstub nicetest && mv bin/nicetest bin/test
```

You can run it now:

```sh
# Run tests
$ bin/test

# In CI
$ bin/test --reporter doc,junit
```

### What about Rakefile?

If you want to use Rake, just do this:

```ruby
# Rakefile

task :test do
  sh("bin/test")
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ianks/nicetest.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
