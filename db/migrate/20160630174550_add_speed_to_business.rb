class AddSpeedToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :speed, :integer
  end
end
