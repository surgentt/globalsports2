class AddFbShareMsgToLeague < ActiveRecord::Migration
  def self.up
    add_column :leagues, :fb_share_msg, :text
  end

  def self.down
    remove_column :leagues, :fb_share_msg
  end
end
