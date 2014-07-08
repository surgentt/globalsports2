class AddVideoAssetIdToAudioTimeline < ActiveRecord::Migration
  def self.up
    add_column :audio_timelines, :video_asset_id, :integer

    remove_column :audio_assets, :audio_timeline_id
    remove_column :audio_assets, :start_position

    create_table :audio_timeline_assets do |t|
      t.string   :audio_asset_id
      t.integer  :audio_timeline_id
      t.integer  :start_position
      t.timestamps
    end
  end

  def self.down
    remove_column :audio_timelines, :video_asset_id

    add_column :audio_assets, :audio_timeline_id, :integer
    add_column :audio_assets, :start_position, :integer

    drop_table :audio_timeline_assets
  end
end
