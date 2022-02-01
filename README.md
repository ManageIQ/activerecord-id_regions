# ActiveRecord::IdRegions

[![Gem Version](https://badge.fury.io/rb/activerecord-id_regions.svg)](http://badge.fury.io/rb/activerecord-id_regions)
[![Build Status](https://travis-ci.org/ManageIQ/activerecord-id_regions.svg)](https://travis-ci.org/ManageIQ/activerecord-id_regions)
[![Code Climate](https://codeclimate.com/github/ManageIQ/activerecord-id_regions.svg)](https://codeclimate.com/github/ManageIQ/activerecord-id_regions)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/activerecord-id_regions/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/activerecord-id_regions/coverage)

[![Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ManageIQ/activerecord-id_regions?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

ActiveRecord extension to allow partitioning ids into regions, for merge replication purposes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-id_regions'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-id_regions

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManageIQ/activerecord-id_regions.

## License

The gem is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).

