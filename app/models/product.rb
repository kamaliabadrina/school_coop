class Product < ApplicationRecord
  has_many :product_options, dependent: :destroy
  has_many :cart_items
  accepts_nested_attributes_for :product_options, allow_destroy: true

  has_one_attached :image

  validate :only_one_option_allowed

  private

  def only_one_option_allowed
    if product_options.size > 1
      errors.add(:product_options, "can only have one option.")
    end
  end
end
