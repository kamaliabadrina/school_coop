class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :buy]
  skip_before_action :authenticate_user!, only: [:index, :show, :buy]

  # GET /products or /products.json
  def index
    @products = Product.all
    if user_signed_in? # Only admins can sign in
      @available_products = Product.where("stock > ?", 0)
      @sold_out_products = Product.where(stock: 0)
    else
      @available_products = Product.where("stock > ?", 0)
    end
  end

  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params[:id])
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def buy
    Rails.logger.info("Received parameters: #{params.inspect}")
  
    quantity = params[:order][:quantity].to_i
  
    # Check if enough stock is available
    if @product.stock < quantity
      redirect_to @product, alert: "Not enough stock available."
      return
    end
  
    @order = Order.new(order_params)
    @order.product = @product 
    @order.price = @order.product.price * quantity
  
    if @order.save
      # Deduct stock after successful order creation
      @product.update(stock: @product.stock - quantity)
  
      Rails.logger.debug "Order Params: #{order_params.inspect}"
      Rails.logger.debug "Updated Stock: #{@product.stock}"
  
      OrderConfirmationJob.perform_later(@order.id)
      redirect_to success_orders_path, notice: "Order was successfully placed. A confirmation email has been sent."
    else
      render :new, status: :unprocessable_entity
    end
  end
  

  private

  def set_product
    @product = Product.find_by(id: params[:id])
    unless @product
      flash[:alert] = "Product not found."
      redirect_to products_path
    end
  end

  def product_params
    params.require(:product).permit(
      :name,
      :price,
      :stock,
      :image,
      product_options_attributes: [
        :id,
        :name,
        :_destroy, # This allows for option removal
        product_option_values_attributes: [
          :id,
          :value,
          :_destroy # This allows for value removal
        ]
      ]
    )
  end
  

  def order_params
    params.require(:order).permit(:user_id, :product_id, :quantity, :status, :kid_name, :price, :kid_class, :payment_info, :email, :options)
  end
end
