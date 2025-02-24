class OrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :success]
  before_action :set_order, only: [:edit, :update, :destroy] # Removed `show` since it's not used

  # GET /orders
  def index
    @orders = Order.all
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

  # POST /orders
  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to success_orders_path, notice: "Order was successfully placed." # Redirect to success page
    else
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

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find_by(id: params[:id])
      unless @order
        flash[:alert] = "Order not found."
        redirect_to orders_path
      end
    end

    # Only allow trusted parameters.
    def order_params
      params.require(:order).permit(:user_id, :product_id, :quantity, :status)
    end
end
