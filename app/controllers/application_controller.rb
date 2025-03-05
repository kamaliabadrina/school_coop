class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  before_action :authenticate_user!, unless: :guest_allowed?

  private

  def guest_allowed?
    Rails.logger.info "🔍 Checking guest access for #{controller_name}##{action_name}"
    controller_name == "orders" && ["new", "create", "paymentredirect", "success"].include?(action_name)
  end
end
