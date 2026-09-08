class CreateRepairs < ActiveRecord::Migration[8.0]
  def change
    create_table :repairs do |t|
      t.bigint :bike_id, null: false
      t.bigint :staff_id
      t.string :status, null: false, default: "Received"
      t.string :approval_status
      t.date :promised_on
      t.datetime :quoted_at
      t.datetime :handed_back_at

      t.timestamps
    end
  end
end