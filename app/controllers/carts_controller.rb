require 'ostruct'

class CartsController < ApplicationController  
  skip_before_action :authenticate_user!, only: [:show, :add_item, :remove_item]

  def show
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      @cart_items = @cart.cart_items
    else
      session[:cart] ||= {}
      @cart_items = session[:cart].map do |product_id, data|
        product = Product.find_by(id: product_id)
        OpenStruct.new(product: product, quantity: data["quantity"], id: product_id, options: data["options"]) if product
      end.compact
    end
  end

  def add_item
    product = Product.find_by(id: params[:product_id])
  
    if product.nil?
      redirect_to cart_path, alert: "Product not found!" and return
    end
  
    quantity = params[:quantity].to_i
    if quantity < 1
      redirect_to cart_path, alert: "Invalid quantity!" and return
    end
  
    selected_options = params[:options] || {} # Assuming options are passed as params
  
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      @cart_item = @cart.cart_items.find_or_initialize_by(product_id: product.id)
      @cart_item.quantity += quantity
      @cart_item.options = selected_options.to_json # Store selected options as JSON
      @cart_item.save
    else
      session[:cart] ||= {}
      session[:cart][product.id.to_s] ||= { "quantity" => 0, "options" => {} }
      session[:cart][product.id.to_s]["quantity"] += quantity
      session[:cart][product.id.to_s]["options"] = selected_options.to_json # Ensure options are stored as JSON
    end
  
    redirect_to cart_path, notice: "Product added to cart!"
  end

  def create_order
    @order = Order.new(order_params)
    @order.user = current_user
    @order.cart_items = @cart.cart_items
    if @order.save
      @cart.cart_items.destroy_all  # Clear the cart after successful order
      redirect_to order_success_path
    else
      render :checkout
    end
  end
  
  def remove_item
    if user_signed_in?
      cart_item = CartItem.find_by(id: params[:id])
      if cart_item
        cart_item.destroy
        redirect_to cart_path, notice: "Item removed from cart!"
      else
        redirect_to cart_path, alert: "Item not found in cart!"
      end
    else
      session[:cart] ||= {}
      if session[:cart].key?(params[:product_id])
        session[:cart].delete(params[:product_id])
        redirect_to cart_path, notice: "Item removed from cart!"
      else
        redirect_to cart_path, alert: "Item not found in cart!"
      end
    end
  end
end
