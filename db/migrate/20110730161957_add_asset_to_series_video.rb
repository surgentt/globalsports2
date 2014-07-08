class AddAssetToSeriesVideo < ActiveRecord::Migration
  def self.up
    add_column :series_videos, :asset_type, :string
    add_column :series_videos, :asset_id, :integer
    add_column :series_videos, :status, :string
  end

  def self.down
    remove_column :series_videos, :asset_type
    remove_column :series_videos, :asset_id
    remove_column :series_videos, :status
  end
end
