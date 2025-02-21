class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: true, foreign_key: true # Allow null user reference
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 1 # Default quantity to 1
      t.string :status

      t.timestamps
    end
  end
end
