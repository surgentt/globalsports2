class AddKeyToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :tag, :string
    add_index :series, :tag

    add_index :series_videos, :media_id

    add_column :series, :timezone, :string
  end

  def self.down
    remove_index :series_videos, :media_id

    remove_index :sent_messages, :tag
    remove_column :series, :tag

    remove_column :series, :timezone
  end
end






