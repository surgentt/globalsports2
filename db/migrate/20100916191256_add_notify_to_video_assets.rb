class AddNotifyToVideoAssets < ActiveRecord::Migration
  def self.up
    add_column :video_assets, :notify_ready, :boolean
  end

  def self.down
    remove_column :video_assets, :notify_ready
  end
end
