# app/models/product.rb
class Product < ApplicationRecord
    has_many :product_options, dependent: :destroy
    has_many :cart_items
    accepts_nested_attributes_for :product_options, allow_destroy: true

    has_one_attached :image

  end
  
  # app/models/product_option.rb
  class ProductOption < ApplicationRecord
    belongs_to :product
    has_many :product_option_values, dependent: :destroy
    accepts_nested_attributes_for :product_option_values, allow_destroy: true
  end
  
  # app/models/product_option_value.rb
  class ProductOptionValue < ApplicationRecord
    belongs_to :product_option
  end
  