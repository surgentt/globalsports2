class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.integer :user_id
      t.string :item_type
      t.integer :item_id
      t.string :description
      t.integer :cost
      t.integer :quantity
      t.boolean :paid
      t.string :status
      t.text :transaction_info

      t.timestamps
    end

    add_index :purchases, :user_id
  end

  def self.down
    drop_table :purchases
  end
end
