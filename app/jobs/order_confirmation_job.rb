class OrderConfirmationJob < ApplicationJob
  queue_as :mailers

  def perform(order_id)
    order = Order.find_by(id: order_id)
    OrderMailer.order_confirmation(order).deliver_now if order
  end
end
