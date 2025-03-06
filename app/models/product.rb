class Product < ApplicationRecord
  has_many :product_options, dependent: :destroy
  has_many :cart_items
  has_many :orders
  accepts_nested_attributes_for :product_options, allow_destroy: true
  before_save :capitalize_name 

  has_one_attached :image

  validate :only_one_option_allowed

  private

  def capitalize_name
    self.name = name.capitalize
  end

  def only_one_option_allowed
    if product_options.size > 1
      errors.add(:product_options, "can only have one option.")
    end
  end
end
