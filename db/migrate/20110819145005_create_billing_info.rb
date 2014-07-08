class CreateBillingInfo < ActiveRecord::Migration
  def self.up
    create_table :billings do |t|
      t.integer :user_id

      t.string :firstname
      t.string :lastname
      t.string :address1
      t.string :address2
      t.string :city
      t.integer :state_id
      t.string :zip

      t.integer :total

      t.string :last_four
      t.text :transaction_info

      t.timestamps
    end

    add_column :purchases, :billing_id, :integer
    add_index :purchases, :billing_id
  end

  def self.down
    drop_table :billings
    remove_column :purchases, :billing_id
  end
end
