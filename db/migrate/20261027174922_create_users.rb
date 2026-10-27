class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "counter"

      t.references :staff,
        null: true,
        foreign_key: true,
        index: { unique: true }

      t.timestamps
    end

    add_index :users,
      "LOWER(email_address)",
      unique: true,
      name: "index_users_on_lower_email_address"
  end
end