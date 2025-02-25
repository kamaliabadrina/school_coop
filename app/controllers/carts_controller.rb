require 'ostruct'

class CartsController < ApplicationController  
  skip_before_action :authenticate_user!, only: [:show, :add_item, :remove_item]

  def show
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      @cart_items = @cart.cart_items
    else
      session[:cart] ||= {}
      @cart_items = session[:cart].map do |product_id, quantity|
        product = Product.find_by(id: product_id)
        OpenStruct.new(product: product, quantity: quantity, id: product_id) if product
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

    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
      @cart_item = @cart.cart_items.find_or_initialize_by(product_id: product.id)
      @cart_item.quantity += quantity
      @cart_item.save
    else
      session[:cart] ||= {}
      session[:cart][product.id.to_s] ||= 0
      session[:cart][product.id.to_s] += quantity
    end

    redirect_to cart_path, notice: "Product added to cart!"
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
