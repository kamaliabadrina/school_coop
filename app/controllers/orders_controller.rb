class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :success]
  before_action :set_order, only: [:edit, :update, :destroy]

  # GET /orders
  def index
    @orders = Order.all
    
    # Calculate total earnings for the current month and today before applying the search
    @total_earnings_today = @orders.where("created_at >= ?", Time.current.beginning_of_day).sum(:price)
    @total_earnings_this_month = @orders.where("created_at >= ?", Time.current.beginning_of_month).sum(:price)
  
    # Store the original orders in a separate variable for calculations
    @all_orders = @orders.dup
  
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @orders = @orders.joins(:product).where(
        "orders.kid_name ILIKE ? OR orders.kid_class ILIKE ? OR orders.status ILIKE ? OR products.name ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
  
    # Calculate total earnings based on the filtered orders if a search was made
    @monthly_earnings = @all_orders.where("extract(month from created_at) = ? AND extract(year from created_at) = ?", Date.today.month, Date.today.year).sum(:price)
  
    # Calculate total earnings for today based on the filtered orders
    @daily_earnings = @all_orders.where("created_at >= ?", Time.zone.now.beginning_of_day).sum(:price)
  end
  
  
  

  # GET /orders/success
  def success
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  def create
    @order = Order.new(order_params)
    @order.options = params[:order][:options] if params[:order][:options].present?
  
    # Find the product using the product_id from the order_params
    product = Product.find_by(id: params[:order][:product_id])
  
    if product
      # Set the order price to the product price
      @order.price = product.price
    else
      # Handle the case where the product is not found
      flash[:alert] = "Product not found."
      render :new, status: :unprocessable_entity and return
    end
  
    if @order.save
      redirect_to @order, notice: "Order successfully created."    
    else
      puts "❌ ORDER FAILED: #{@order.errors.full_messages}"  # Debugging
      flash[:alert] = "Failed to place order: #{@order.errors.full_messages.join(", ")}"
      render :new, status: :unprocessable_entity
    end
  end
  

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
      redirect_to success_orders_path, notice: "Order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /orders/1
  def destroy
    @order.destroy!
    redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed."
  end

  private

    def set_order
      @order = Order.find_by(id: params[:id])
      unless @order
        flash[:alert] = "Order not found."
        redirect_to orders_path
      end
    end

    private

    def order_params
      params.require(:order).permit(:email, :kid_name, :kid_class, :payment_info, :product_id, :quantity, :price)
    end    
end
