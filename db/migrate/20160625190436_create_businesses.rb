class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :address
      t.string :email
      t.string :website
      t.string :phone
      t.string :responsive

      t.timestamps null: false
    end
  end
end
