class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.decimal :current_price, precision: 8, scale: 2, null: false

      t.timestamps

      t.index :name, unique: true
    end
  end
end