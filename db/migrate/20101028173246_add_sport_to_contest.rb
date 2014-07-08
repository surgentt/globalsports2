class AddSportToContest < ActiveRecord::Migration
  def self.up
    add_column :contests, :sport, :string
  end

  def self.down
    remove_column :contests, :sport
  end
end
