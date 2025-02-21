class AddDetailsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :kid_name, :string
    add_column :orders, :kid_class, :string
    add_column :orders, :payment_info, :string
  end
end
