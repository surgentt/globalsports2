class AddUserToFileAssets < ActiveRecord::Migration
  def self.up
    add_column :file_assets, :user_id, :integer
    add_column :file_assets, :asset_type, :string
    add_column :file_assets, :asset_id, :integer
    add_column :file_assets, :agent, :string
  end

  def self.down
    remove_column :file_assets, :user_id
    remove_column :file_assets, :asset_type
    remove_column :file_assets, :asset_id
    remove_column :file_assets, :agent
  end
end
