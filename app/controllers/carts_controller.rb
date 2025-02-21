require 'ostruct'

class CartsController < ApplicationController  
  skip_before_action :authenticate_user!, only: [:show, :add_item, :remove_item]

  def show
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      @cart_items = @cart.cart_items
    else
      session[:cart] ||= {}  # Ensure session cart exists
      @cart_items = session[:cart].map do |product_id, quantity|
        product = Product.find_by(id: product_id)
        OpenStruct.new(product: product, quantity: quantity, id: product_id) if product
      end.compact
    end
  end
  

  def add_item
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      @cart_item = @cart.cart_items.find_or_initialize_by(product_id: params[:product_id])
      @cart_item.quantity += params[:quantity].to_i
      @cart_item.save
    else
      session[:cart] ||= {}
      session[:cart][params[:product_id]] ||= 0
      session[:cart][params[:product_id]] += params[:quantity].to_i
    end
    redirect_to cart_path, notice: "Product added to cart!"
  end

  def remove_item
    if user_signed_in?
      @cart_item = CartItem.find(params[:id])
      @cart_item.destroy
    else
      session[:cart].delete(params[:product_id]) # Use product_id instead of id
    end
  
    redirect_to cart_path, notice: "Product removed from cart!"
  end
  
  
end
