class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:paymentredirect, :success, :payment_failed]
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  def index
    @orders = Order.includes(:product)  # Eager load products to avoid N+1 queries
    
    # Specify orders.created_at to avoid ambiguity
    @total_earnings_today = @orders.where("orders.created_at >= ?", Time.current.beginning_of_day)
                                   .sum { |order| order.product.price * order.quantity }
  
    @total_earnings_this_month = @orders.where("orders.created_at >= ?", Time.current.beginning_of_month)
                                        .sum { |order| order.product.price * order.quantity }
  
    @all_orders = @orders.dup
  
    # If a search term is present, filter the orders
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @orders = @orders.joins(:product).where(
        "orders.kid_name ILIKE ? OR orders.kid_class ILIKE ? OR orders.status ILIKE ? OR products.name ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
  
    # Fix ambiguity in created_at column
    @monthly_earnings = @orders.sum { |order| order.product.price * order.quantity }
    @daily_earnings = @orders.where("orders.created_at >= ?", Time.zone.now.beginning_of_day)
                             .sum { |order| order.product.price * order.quantity }
  
    # Group orders by product name
    @grouped_orders = @orders.group_by { |order| order.product.name }
  end
  

  protect_from_forgery except: :paymentredirect # Allow SecurePay callback

  def paymentredirect
    Rails.logger.info "✅ Received SecurePay Payment Callback: #{params.inspect}"
  
    # Validate SecurePay response
    if params[:status] == "success" && params[:transaction_id].present?
      # Create and save the order now
      order = Order.create!(
        product_id: params[:product_id], 
        kid_name: params[:buyer_name], 
        phone_number: params[:buyer_phone], 
        price: params[:transaction_amount], 
        status: "paid",
        payment_reference: params[:transaction_id]
      )
  
      Rails.logger.info "✅ Payment successful, Order #{order.id} saved!"
      redirect_to order_path(order), notice: "Payment processed successfully!"
    else
      Rails.logger.error "❌ Payment failed"
      redirect_to payment_failed_path, alert: "Payment failed. Please try again."
    end
  end
  

  # GET /orders/success
  def success
  end

  def payment_failed
    @order = Order.find(params[:id])
  end
  

  # GET /orders/:id
  def show
    if current_user && !current_user.admin? && @order.user != current_user
      redirect_to root_path, alert: "Unauthorized access"
    end
  end  

  # DELETE /orders/:id
  def destroy
    @order.destroy!
    redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed."
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
