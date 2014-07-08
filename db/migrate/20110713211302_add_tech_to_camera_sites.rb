class AddTechToCameraSites < ActiveRecord::Migration
  def self.up
    add_column :camera_sites, :contact_title, :string
    add_column :camera_sites, :tech_name, :string
    add_column :camera_sites, :tech_phone, :string
    add_column :camera_sites, :tech_email, :string
  end

  def self.down
    remove_column :camera_sites, :contact_title
    remove_column :camera_sites, :tech_name
    remove_column :camera_sites, :tech_phone
    remove_column :camera_sites, :tech_email
  end
end
