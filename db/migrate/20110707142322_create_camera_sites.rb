class CreateCameraSites < ActiveRecord::Migration
  def self.up
    create_table :camera_sites do |t|
      t.string :league_name
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :name
      t.string :address
      t.string :county
      t.string :city
      t.integer :state_id
      t.string :zip
      t.integer :fields
      t.string :network
      t.string :scoreboard
      t.string :power_dist
      t.string :network_dist
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :camera_sites
  end
end
