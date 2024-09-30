source 'https://rubygems.org'

# Specify your gem's dependencies in activerecord-id_regions.gemspec
gemspec

minimum_version =
  case ENV['TEST_RAILS_VERSION']
  when "7.2"
    "~>7.2.1"
  when "7.1"
    "~>7.1.4"
  else
    "~>7.0.8"
  end

gem "activerecord", minimum_version
gem "activesupport", minimum_version
