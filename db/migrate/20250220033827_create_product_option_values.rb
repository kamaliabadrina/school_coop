class CreateProductOptionValues < ActiveRecord::Migration[8.0]
  def change
    create_table :product_option_values do |t|
      t.string :value
      t.references :product_option, null: false, foreign_key: true

      t.timestamps
    end
  end
end
