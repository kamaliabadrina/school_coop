class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :success]
  before_action :set_order, only: [:edit, :update, :destroy]

  # GET /orders
  # GET /orders
def index
  @orders = Order.includes(:product)  # Eager load products to avoid N+1 queries

  # Calculate total earnings for today
  @total_earnings_today = @orders.where("created_at >= ?", Time.current.beginning_of_day)
                                 .sum { |order| order.product.price * order.quantity }

  # Calculate total earnings for the current month
  @total_earnings_this_month = @orders.where("created_at >= ?", Time.current.beginning_of_month)
                                      .sum { |order| order.product.price * order.quantity }

  # Store the original orders before filtering for search
  @all_orders = @orders.dup

  if params[:search].present?
    search_term = "%#{params[:search]}%"
    @orders = @orders.joins(:product).where(
      "orders.kid_name ILIKE ? OR orders.kid_class ILIKE ? OR orders.status ILIKE ? OR products.name ILIKE ?",
      search_term, search_term, search_term, search_term
    )
  end

  # Calculate total earnings for the current month based on the filtered orders
  @monthly_earnings = @orders.sum { |order| order.product.price * order.quantity }

  # Calculate total earnings for today based on the filtered orders
  @daily_earnings = @orders.where("created_at >= ?", Time.zone.now.beginning_of_day)
                           .sum { |order| order.product.price * order.quantity }
end

# POST /products/1/buy
def buy
  Rails.logger.info("Received parameters: #{params.inspect}")

  @order = Order.new(order_params)
  @order.product = @product 
  @order.price = @order.product.price

  if @order.save
    Rails.logger.debug "Order Params: #{order_params.inspect}"
    # Send order confirmation email in background
    OrderConfirmationJob.perform_later(@order.id)
    redirect_to success_orders_path, notice: "Order was successfully placed. A confirmation email has been sent."
  else
    render :new, status: :unprocessable_entity
  end
end
  
  # GET /orders/success
  def success
  end

  # DELETE /orders/1
  def destroy
    @order.destroy!
    redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed."
  end

  def order_params
    # Permit the parameters coming from the form
      params.require(:order).permit(:user_id, :product_id, :quantity, :status, :kid_name, :price, :kid_class, :payment_info, :email, options: {})
  end
end
