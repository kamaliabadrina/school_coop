class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :product
  has_many :order_options, dependent: :destroy
  accepts_nested_attributes_for :order_options
  
end
