module ActiveRecord::IdRegions
  module Migration
    ALLOWED_ID_VALUES = [false, :uuid, "uuid"].freeze

    def create_table(table_name, options = {})
      options[:id] = :bigserial unless ALLOWED_ID_VALUES.include?(options[:id])
      value = anonymous_class_with_id_regions.rails_sequence_start
      super
      return if ALLOWED_ID_VALUES.include?(options[:id])

      set_pk_sequence!(table_name, value) unless value == 0
    end

    def anonymous_class_with_id_regions
      ActiveRecord::IdRegions::Migration.anonymous_class_with_id_regions
    end

    def self.anonymous_class_with_id_regions
      @class_with_id_regions ||= Class.new(ActiveRecord::Base).include(ActiveRecord::IdRegions)
    end
  end
end
