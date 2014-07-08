class CreateSeries < ActiveRecord::Migration
  def self.up
    create_table :series do |t|
      t.string :host_key

      t.string :name
      t.string :location
      t.datetime :start
      t.datetime :date

      t.timestamps
    end
  end

  def self.down
    drop_table :series
  end
end
