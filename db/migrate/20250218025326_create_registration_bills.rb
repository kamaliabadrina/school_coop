class CreateRegistrationBills < ActiveRecord::Migration[8.0]
  def change
    create_table :registration_bills do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :status

      t.timestamps
    end
  end
end
