require 'openssl'

class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :product
  before_save :capitalize_name
  #after_save :delete_if_payment_failed

  def capitalize_name
    self.kid_name = kid_name.upcase
  end

  #def delete_if_payment_failed
   # if payment_status == "failed" && "pending"
    #  destroy
    #end
  #end

  def generate_checksum
    Rails.logger.info("Generating checksum for order #{id}")
    string = "#{email}|#{kid_name}|#{phone_number}||#{id}|#{product.name}|http://localhost:3000/orders/#{id}/paymentredirect|#{price}|b66c2a38-52f5-4e34-b1a3-520cf5741191"
    puts(string)
    checksum_token = "4c30de911cb3a5f1957e9ee8f5acd285f5a464eb7e6fec89d301537393565b53"
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), checksum_token, string)
  end
end
