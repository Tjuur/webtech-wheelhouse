class AddReceivedByUserToRepairs < ActiveRecord::Migration[8.0]
  def change
    add_reference :repairs,
      :received_by_user,
      null: true,
      foreign_key: { to_table: :users }
  end
end
