class CreateFileAssets < ActiveRecord::Migration
  def self.up
    create_table :file_assets do |t|
      t.string :name
      t.string :location
      t.string :status
      t.integer :last_block
      t.integer :block_count
      t.integer :size
      t.string :md5

      t.timestamps
    end
  end

  def self.down
    drop_table :file_assets
  end
end
