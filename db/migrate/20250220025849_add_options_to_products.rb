class AddOptionsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :options, :json
  end
end
