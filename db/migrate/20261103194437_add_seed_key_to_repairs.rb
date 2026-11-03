class AddSeedKeyToRepairs < ActiveRecord::Migration[8.1]
  def change
    add_column :repairs, :seed_key, :string
    add_index :repairs, :seed_key, unique: true
  end
end
