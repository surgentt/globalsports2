class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
    end

    Role.enumeration_model_updates_permitted = true
    Role.create(:name => 'admin')    
    Role.create(:name => 'moderator')
    Role.create(:name => 'member')            
    Role.enumeration_model_updates_permitted = false
    
    add_column :users, :role_id, :integer

    #set all existing users to 'member'
    # User.update_all("role_id = #{Role[:member].id}", ["admin = ?", false])
    execute "update users set role_id = (select id from roles where name = 'member') where admin != 1"
    #set admins to 'admin'
    # User.update_all("role_id = #{Role[:admin].id}", ["admin = ?", true])
    execute "update users set role_id = (select id from roles where name = 'admin') where admin = 1"

    remove_column :users, :admin
  end

  def self.down
    drop_table :roles
    remove_column :users, :role_id
    add_column :users, :admin, :boolean, :default => false
  end
end
