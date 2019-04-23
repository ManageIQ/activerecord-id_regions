describe ActiveRecord::IdRegions::Migration do
  migration_versions.each do |version|
    it "Ensures starting sequence on newly created tables for #{version} migrations" do
      expect(ENV).to receive(:fetch).with("REGION", nil).and_return(nil)
      region_number_before = TestRecord.region_number_from_sequence
      described_class.anonymous_class_with_id_regions.clear_region_cache

      allow(described_class.anonymous_class_with_id_regions.connection).to receive(:select_value).and_wrap_original do |m, arg|
        if arg == "SELECT relname FROM pg_class WHERE relkind = 'S' LIMIT 1"
          # HACK: the order so that we get the most recently created
          m.call("SELECT relname FROM pg_class WHERE relkind = 'S' ORDER BY oid DESC LIMIT 1")
        else
          m.call(arg)
        end
      end

      suppress_migration_messages do
        Class.new(ActiveRecord::Migration[version]) do
          def change
            create_table :testing_correct_sequence
          end
        end.migrate(:up)
      end

      expect(TestRecord.id_to_region(ActiveRecord::Base.connection.select_value("SELECT last_value FROM testing_correct_sequence_id_seq"))).to eq(region_number_before)
    end

    context "Tests create_table for #{version} migrations" do
      let(:klass) { Class.new(ActiveRecord::Base) }

      it "id => false, creates no id column" do
        suppress_migration_messages do
          Class.new(ActiveRecord::Migration[version]) do
            def change
              create_table :testing_create_table_id_false, :id => false do |t|
                t.string "name"
              end
            end
          end.migrate(:up)
        end

        klass.table_name = :testing_create_table_id_false
        expect(klass.attribute_names.sort).to eq(%w[name])
      end

      it "implicit id, creates bigserial id" do
        suppress_migration_messages do
          Class.new(ActiveRecord::Migration[version]) do
            def change
              create_table :testing_create_table_implicit_id do |t|
                t.string "name"
              end
            end
          end.migrate(:up)
        end

        klass.table_name = :testing_create_table_implicit_id
        expect(klass.attribute_names.sort).to eq(%w[id name])
        expect(ActiveRecord::Base.connection.select_value("SELECT last_value FROM #{klass.table_name}_id_seq")).to be > TestRecord::DEFAULT_RAILS_SEQUENCE_FACTOR
      end

      it "id => integer, creates bigserial id" do
        suppress_migration_messages do
          Class.new(ActiveRecord::Migration[version]) do
            def change
              create_table :testing_create_table_integer_id, :id => :integer do |t|
                t.string "name"
              end
            end
          end.migrate(:up)
        end

        klass.table_name = :testing_create_table_integer_id
        expect(klass.attribute_names.sort).to eq(%w[id name])
        expect(ActiveRecord::Base.connection.select_value("SELECT last_value FROM #{klass.table_name}_id_seq")).to be > TestRecord::DEFAULT_RAILS_SEQUENCE_FACTOR
      end
    end
  end
end
