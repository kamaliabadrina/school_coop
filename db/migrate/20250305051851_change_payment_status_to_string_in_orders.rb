class ChangePaymentStatusToStringInOrders < ActiveRecord::Migration[7.0]
  def up
    change_column :orders, :payment_status, :string, default: "pending"
  end

  def down
    change_column :orders, :payment_status, :integer
  end
end
