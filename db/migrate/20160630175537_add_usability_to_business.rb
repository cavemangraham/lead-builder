class AddUsabilityToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :usability, :integer
  end
end
