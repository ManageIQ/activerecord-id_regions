if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

require "bundler/setup"
require "active_record/id_regions"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.before(:suite) do
    drop_test_database
    create_test_database
  end

  config.before do
    ActiveRecord::Base.connection.begin_transaction
  end

  config.after do
    ActiveRecord::Base.connection.rollback_transaction if ActiveRecord::Base.connection.transaction_open?
  end

  config.after(:suite) do
    drop_test_database
  end
end

RSpec::Matchers.define :a_region_pathname do
  match { |actual| actual.kind_of?(Pathname) && actual.to_s.end_with?("REGION") }
end

DB_NAME = "activerecord_id_regions_test".freeze

def drop_test_database
  ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "postgres")
  ActiveRecord::Base.connection.drop_database(DB_NAME)
end

def create_test_database
  ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "postgres")
  ActiveRecord::Base.connection.create_database(DB_NAME)
  ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => DB_NAME)
  suppress_migration_messages { with_random_region { CreateTestRecordsTable.migrate(:up) } }
end

def with_random_region
  old_env = ENV.delete("REGION")
  ENV["REGION"] = rand(1..99).to_s
  yield
ensure
  ENV["REGION"] = old_env
end

ActiveRecord::Migration.include(ActiveRecord::IdRegions::Migration)

def suppress_migration_messages
  save, ActiveRecord::Migration.verbose = ActiveRecord::Migration.verbose, false
  yield
ensure
  ActiveRecord::Migration.verbose = save
end

def migration_versions
  [5.2, 5.1, 5.0, 4.2].select { |v| ActiveRecord::VERSION::STRING >= v.to_s }
end

class TestRecord < ActiveRecord::Base
  include ActiveRecord::IdRegions
end

class CreateTestRecordsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :test_records, :id => :bigserial
  end
end

require "active_record"
require "active_support"
puts
puts "\e[93mUsing ActiveRecord #{ActiveRecord.version}\e[0m"
puts "\e[93mUsing ActiveSupport #{ActiveSupport.version}\e[0m"
