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

DB_NAME = "activerecord_id_regions_test".freeze

def drop_test_database
  ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "postgres")
  ActiveRecord::Base.connection.drop_database(DB_NAME)
end

def create_test_database
  ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "postgres")
  ActiveRecord::Base.connection.create_database(DB_NAME)
  ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => DB_NAME)
  ActiveRecord::Base.connection.create_table("test_records", :id => :bigserial)
end

class TestRecord < ActiveRecord::Base
  include ActiveRecord::IdRegions
end
