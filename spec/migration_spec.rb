describe ActiveRecord::IdRegions::Migration do
  it "Tests that we get the correct starting sequence on newly created tables when region is determined from sequence" do
    expect(ENV).to receive(:fetch).with("REGION", nil).and_return(nil)
    region_number_before = TestRecord.region_number_from_sequence
    described_class.anonymous_class_with_id_regions.clear_region_cache

    allow(described_class.anonymous_class_with_id_regions.connection).to receive(:select_value).and_wrap_original do |m, arg|
      if arg == "SELECT relname FROM pg_class WHERE relkind = 'S' LIMIT 1"
        # HACK the order so that we get the most recently created
        m.call("SELECT relname FROM pg_class WHERE relkind = 'S' ORDER BY oid DESC LIMIT 1")
      else
        m.call(arg)
      end
    end

    Class.new(ActiveRecord::Migration[5.0]) do
      def change
        create_table :testing_correct_sequence
      end
    end.migrate(:up)

    expect(TestRecord.id_to_region(ActiveRecord::Base.connection.select_value("SELECT last_value FROM testing_correct_sequence_id_seq"))).to eq(region_number_before)
  end
end
