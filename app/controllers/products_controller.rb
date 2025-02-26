class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :buy]
  skip_before_action :authenticate_user!, only: [:index, :show, :buy]

  # GET /products or /products.json
  def index
    @products = Product.all
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

 # POST /products/1/buy
  def buy
    Rails.logger.info("Received parameters: #{params.inspect}")

    @order = Order.new(order_params)
    @order.product = @product 

    if @order.save
      redirect_to success_orders_path, notice: 'Your order was placed successfully!'
    else
      flash.now[:alert] = 'There was a problem creating the order. Please check your inputs.'
      Rails.logger.info("Order errors: #{@order.errors.full_messages}")
      render :show
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
    params.require(:product).permit(:name, :price, :stock, :image, product_options_attributes: [:id, :name, :_destroy, product_option_values_attributes: [:id, :value, :_destroy]])
  end

  def order_params
    # Permit the parameters coming from the form
    params.require(:order).permit(:kid_name, :kid_class, :payment_info, :quantity)
  end
end
