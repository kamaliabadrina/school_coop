# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
# test/mailers/previews/order_mailer_preview.rb

class OrderMailerPreview < ActionMailer::Preview
    # Preview the order confirmation email
    def order_confirmation
      # Assuming you have a User and Order model
      user = User.first || User.new(email: "test@example.com")
      order = Order.new(kid_name: "John Doe", kid_class: "1A", payment_info: "Credit Card", quantity: 1)
      
      OrderMailer.with(user: user, order: order).order_confirmation
    end
  end
  
