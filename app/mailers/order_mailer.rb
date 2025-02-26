class OrderMailer < ApplicationMailer
    default from: 'Co-op@example.com'  
  
    def order_confirmation(order)
      @order = order
      mail(to: @order.email, subject: 'Order Confirmation')
    end
  end
  