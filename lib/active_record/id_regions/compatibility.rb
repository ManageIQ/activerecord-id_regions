# Rails 5.1+ changed the default primary key type from integer to bigserial in:
# https://github.com/rails/rails/pull/26266
# With this change, they modified the default compatibility layer for versions
# less than 5.1 to default to integer if not provided.  Since we want our
# default to be bigint/bigserial for those old migrations, we need to prepend
# our module on the migration class for old migrations.
#
# Because activerecord may introduce create_table methods at various versions in
# the compatibility stack, we need to prepend the patch at the point in which it
# retrieves one of the version classes.
module ActiveRecord::IdRegions
  module Compatibility
    def find(*)
      super.tap { |klass| klass.prepend(ActiveRecord::IdRegions::Migration) }
    end
  end
end
