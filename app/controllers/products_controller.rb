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

  def paymentredirect
    order = Order.find_by(id: params[:id])
  
    unless order
      redirect_to orders_path, alert: "Order not found."
      return
    end
  
    payment_status = params[:payment_status]
  
    # Save payment details
    payment_details = {
      payment_id: params[:payment_id],
      order_number: params[:order_number],
      payment_method: params[:payment_method],
      payment_status: params[:payment_status],
      receipt_url: params[:receipt_url],
      status_url: params[:status_url],
      retry_url: params[:retry_url],
      buyer_email: params[:buyer_email],
      buyer_name: params[:buyer_name],
      buyer_phone: params[:buyer_phone],
      transaction_amount: params[:transaction_amount]
    }
    @payment = Payment.new(payment_details)
    @payment.save
  
    if payment_status == "true"
      # Payment success: update order and deduct stock
      if order.product.stock >= order.quantity
        order.update(status: "paid")
        order.product.update(stock: order.product.stock - order.quantity)
        redirect_to order_path(order.id), notice: "Payment successful! Your order is confirmed."
      else
        order.update(status: "failed")
        redirect_to orders_path, alert: "Payment successful, but stock is no longer available. Please contact support."
      end
    else
      order.update(status: "failed")
      redirect_to payment_failed_path(order.id), alert: "Payment failed. Please try again."
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
    @order.payment_status = "pending"  # Order is not paid yet
  
    if @order.save
      Rails.logger.debug "Order Params: #{order_params.inspect}"
  
      OrderConfirmationJob.perform_later(@order.id) # Send confirmation email
  
      # Redirect to SecurePay for payment
      @payment_params = {  # Store in @payment_params so the view can access it
        buyer_email: @order.email, 
        order_number: @order.id,
        buyer_name: @order.kid_name,
        buyer_phone: @order.phone_number,
        transaction_amount: @order.price,
        product_description: @order.product.name,
        callback_url: "",
        redirect_url: "http://localhost:3000/orders/#{@order.id}/paymentredirect",
        uid: 'b66c2a38-52f5-4e34-b1a3-520cf5741191',
        token: 'UTxHFAuXARwCLpespe8x',
        checksum: @order.generate_checksum,
        redirect_post: "true"
      }
        render :securepay_form    
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
    params.require(:order).permit(:user_id, :product_id, :quantity, :status, :kid_name, :price, :kid_class, :payment_info, :phone_number, :email, :options)
  end
end
