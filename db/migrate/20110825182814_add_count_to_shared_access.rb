class AddCountToSharedAccess < ActiveRecord::Migration
  def self.up
    add_column :shared_accesses, :fb_like, :integer
    add_column :shared_accesses, :fb_share, :integer
  end

  def self.down
    remove_column :shared_accesses, :fb_like
    remove_column :shared_accesses, :fb_share
  end
end
