require "active_record"
require "active_support/concern"

require "active_record/id_regions/migration"
require "active_record/id_regions/version"

module ActiveRecord::IdRegions
  extend ActiveSupport::Concern

  DEFAULT_RAILS_SEQUENCE_FACTOR = 1_000_000_000_000
  COMPRESSED_ID_SEPARATOR = 'r'.freeze
  CID_OR_ID_MATCHER = "\\d+?(#{COMPRESSED_ID_SEPARATOR}\\d+)?".freeze
  RE_COMPRESSED_ID = /^(\d+)#{COMPRESSED_ID_SEPARATOR}(\d+)$/

  module ClassMethods
    def my_region_number(force_reload = false)
      clear_region_cache if force_reload
      @@my_region_number ||= discover_my_region_number
    end

    def rails_sequence_factor
      @@rails_sequence_factor ||= DEFAULT_RAILS_SEQUENCE_FACTOR
    end

    def rails_sequence_factor=(factor)
      @@rails_sequence_factor = factor
    end

    def rails_sequence_start(region_number = my_region_number)
      region_number * rails_sequence_factor
    end

    def rails_sequence_end(region_number = my_region_number)
      rails_sequence_start(region_number) + rails_sequence_factor - 1
    end

    def rails_sequence_range(region_number = my_region_number)
      rails_sequence_start(region_number)..rails_sequence_end(region_number)
    end

    def clear_region_cache
      @@my_region_number = nil
    end

    def id_to_region(id)
      id.to_i / rails_sequence_factor
    end

    def id_in_region(id, region_number)
      region_number * rails_sequence_factor + id
    end

    def region_to_range(region_number)
      (region_number * rails_sequence_factor)..(region_number * rails_sequence_factor + rails_sequence_factor - 1)
    end

    def region_to_conditions(region_number, col = "id")
      ["#{col} >= ? AND #{col} <= ?", *region_to_array(region_number)]
    end

    def region_to_array(region_number)
      range = region_to_range(region_number)
      [range.first, range.last]
    end

    def in_my_region
      in_region(my_region_number)
    end

    def in_region(region_number)
      region_number.nil? ? all : where(:id => region_to_range(region_number))
    end

    def with_region(region_number)
      where(:id => region_to_range(region_number)).scoping { yield }
    end

    def id_in_current_region?(id)
      id_to_region(id) == my_region_number
    end

    def split_id(id)
      return [my_region_number, nil] if id.nil?
      id = uncompress_id(id)

      region_number = id_to_region(id)
      short_id      = (region_number == 0) ? id : id % (region_number * rails_sequence_factor)

      return region_number, short_id
    end

    #
    # ID compression
    #

    def compressed_id?(id)
      id.to_s =~ /^#{CID_OR_ID_MATCHER}$/
    end

    def compress_id(id)
      return nil if id.nil?
      region_number, short_id = split_id(id)
      (region_number == 0) ? short_id.to_s : "#{region_number}#{COMPRESSED_ID_SEPARATOR}#{short_id}"
    end

    def uncompress_id(compressed_id)
      return nil if compressed_id.nil?
      compressed_id.to_s =~ RE_COMPRESSED_ID ? ($1.to_i * rails_sequence_factor + $2.to_i) : compressed_id.to_i
    end

    #
    # Helper methods
    #

    # Partition the passed AR objects into local and remote sets
    def partition_objs_by_remote_region(objs)
      objs.partition(&:in_current_region?)
    end

    # Partition the passed ids into local and remote sets
    def partition_ids_by_remote_region(ids)
      ids.partition { |id| self.id_in_current_region?(id) }
    end

    def group_ids_by_region(ids)
      ids.group_by { |id| id_to_region(id) }
    end

    def region_number_from_sequence
      sequence_name = connection.select_value("SELECT relname FROM pg_class WHERE relkind = 'S' LIMIT 1")
      return if sequence_name.nil?
      id_to_region(connection.select_value("SELECT last_value FROM #{sequence_name}"))
    end

    private

    def discover_my_region_number
      region_file = Rails.root.join("REGION") if defined?(Rails)
      region_num = File.read(region_file) if region_file && File.exist?(region_file)
      region_num ||= ENV.fetch("REGION", nil)
      region_num ||= region_number_from_sequence
      region_num.to_i
    end
  end

  def my_region_number
    self.class.my_region_number
  end

  def in_current_region?
    region_number == my_region_number
  end

  def region_number
    id ? (id / self.class.rails_sequence_factor) : my_region_number
  end
  alias_method :region_id, :region_number

  def region_description
    miq_region.description if miq_region
  end

  def compressed_id
    self.class.compress_id(id)
  end

  def split_id
    self.class.split_id(id)
  end
end
