class AddMediaIdToVideoAssets < ActiveRecord::Migration
  def self.up
    add_column :video_assets, :host_key, :string
    add_column :video_assets, :media_id, :string
  end

  def self.down
    remove_column :video_assets, :host_key
    remove_column :video_assets, :media_id
  end
end
