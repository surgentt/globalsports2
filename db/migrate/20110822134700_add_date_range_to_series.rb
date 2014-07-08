class AddDateRangeToSeries < ActiveRecord::Migration
  def self.up
    remove_column :series, :date
    add_column :series, :end, :datetime
  end

  def self.down
    remove_column :series, :end
  end
end
