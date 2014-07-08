class AddCLipMsgToLeague < ActiveRecord::Migration
  def self.up
    add_column :leagues, :pre_clip_msg, :text
    add_column :leagues, :post_clip_msg, :text
  end

  def self.down
    remove_column :leagues, :pre_clip_msg
    remove_column :leagues, :post_clip_msg
  end
end
