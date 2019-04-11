describe ActiveRecord::IdRegions::Compatibility do
  describe "verifies the ancestors" do
    migration_versions.each do |migration_version|
      it "for ActiveRecord::Migration[#{migration_version}]" do
        expect(ActiveRecord::Migration[migration_version].ancestors.first).to eq(ActiveRecord::IdRegions::Migration)
      end
    end
  end
end
