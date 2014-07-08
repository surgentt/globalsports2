class AddMotdToLeague < ActiveRecord::Migration
  def self.up
    add_column :leagues, :motd, :text
  end

  def self.down
    remove_column :leagues, :motd
  end
end
