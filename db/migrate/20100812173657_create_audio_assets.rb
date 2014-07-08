class CreateAudioAssets < ActiveRecord::Migration
  def self.up

    create_table :audio_assets do |t|
      t.string   :title
      t.integer  :user_id
      
      t.string   :status
      t.string   :filename
      t.text     :internal_notes

      t.string   :dockey
      t.integer  :length
      t.string   :type

      #deprecated
      t.integer  :start_position
      t.integer  :audio_timeline_id


      t.timestamps
    end


    create_table :audio_timelines do |t|
      t.string   :name
      t.integer  :user_id

      t.string   :status
      
      t.timestamps
    end

  end

  def self.down
    drop_table :audio_assets
    drop_table :audio_timelines
  end

end
