class AddOptionsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :options, :jsonb, default: {}  
  end
end
