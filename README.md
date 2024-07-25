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

# Run a test
❯ nicetest --reporter doc test/integration/capture_test.rb:14
Started with run options --reporter doc --name=/CaptureTest#test_capture_with_hyphen_in_variable_name/ --seed 24518

CaptureTest
  test_capture_with_hyphen_in_variable_name                       PASS (0.00s)

Finished in 0.00115s
1 tests, 1 assertions, 0 failures, 0 errors, 0 skips

# JUnit is easy
❯ nicetest --reporter junit,progress                          
Emptying /Users/ianks/Code/Shopify/liquid/tmp/nicetest/junit/1721874837
Started with run options --reporter junit,progress --seed 36139

  799/799: [================================================================================] 100% Time: 00:00:00, Time: 00:00:00
Writing XML reports to /Users/ianks/Code/Shopify/liquid/tmp/nicetest/junit/1721874837

Finished in 0.94625s
799 tests, 1924 assertions, 0 failures, 0 errors, 0 skips

# Filter by name
❯ nicetest --name=/assign/ 
Started with run options --name=/assign/ --seed 44734

  33/33: [====================================================================================] 100% Time: 00:00:00, Time: 00:00:00

Finished in 0.03157s
33 tests, 69 assertions, 0 failures, 0 errors, 0 skips
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

## Recognition

- [minitest] for superb testing
- [minitest-reporters] for the excellent reporting
- [super_diff] for the pretty diffs
- [prism] for the blissful parser
- [pastel] for the pretty colors

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ianks/nicetest.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

[minitest]: https://github.com/minitest/minitest
[minitest-reporters]: https://github.com/minitest-reporters/minitest-reporters
[super_diff]: https://github.com/mcmire/super_diff
[prism]: https://github.com/ruby/prism
[pastel]: https://github.com/piotrmurach/pastel
