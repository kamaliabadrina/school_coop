class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :success]
  before_action :set_order, only: [:edit, :update, :destroy]

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
  
  
  # GET /orders/success
  def success
  end

  # DELETE /orders/1
  def destroy
    @order.destroy!
    redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed."
  end
end
