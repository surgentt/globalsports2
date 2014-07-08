class CreateVeAssets < ActiveRecord::Migration
  def self.up
    create_table :v4_assets do |t|
    #create_table(:v4_assets, :options => 'ENGINE=MyISAM') do |t|

      t.string :name
      t.string :media_id

      t.timestamps
    end
  end

  def self.down
    drop_table :v4_assets
  end
end
