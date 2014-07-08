class CreateSeriesVideos < ActiveRecord::Migration
  def self.up
    create_table :series_videos do |t|
      t.integer :series_id

      t.string :media_id

      t.string :title
      t.datetime :time
      t.string :sport

      t.timestamps
    end
  end

  def self.down
    drop_table :series_videos
  end
end
