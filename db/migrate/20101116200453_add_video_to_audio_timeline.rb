class AddVideoToAudioTimeline < ActiveRecord::Migration
  def self.up
    add_column :audio_timelines, :video_id, :integer 
    add_column :audio_timelines, :video_type, :string
  end

  def self.down
    remove_column :audio_timelines, :video_id
    remove_column :audio_timelines, :video_type
  end
end
