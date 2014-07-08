class AddBrandToCameraSite < ActiveRecord::Migration
  def self.up
    add_column :camera_sites, :brand, :string
  end

  def self.down
    remove_column :camera_sites, :brand
  end
end
