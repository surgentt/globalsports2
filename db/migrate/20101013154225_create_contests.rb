class CreateContests < ActiveRecord::Migration
  def self.up
#    create_table :contests do |t|
#      t.string   :key
#      t.integer  :league_id
#      t.text     :header
#      t.timestamps
#    end
    add_column :contests, :league_id, :integer
    add_column :contests, :tag_name, :string
    add_column :contests, :header, :text
    add_column :contests, :footer, :text

  end

  def self.down
    #drop_table :contests
    remove_column :contests, :league_id
    remove_column :contests, :tag
    remove_column :contests, :header
    remove_column :contests, :footer
  end
end
