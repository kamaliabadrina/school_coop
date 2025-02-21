class ProductOption < ApplicationRecord
  belongs_to :product
  has_many :product_option_values, dependent: :destroy
  accepts_nested_attributes_for :product_option_values, allow_destroy: true

end
