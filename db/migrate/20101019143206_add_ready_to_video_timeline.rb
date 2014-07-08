class AddReadyToVideoTimeline < ActiveRecord::Migration
  def self.up
    add_column :audio_timelines, :status, :string
  end

  def self.down
    remove_column :audio_timelines, :status
  end
end
