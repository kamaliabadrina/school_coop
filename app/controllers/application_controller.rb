class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!, except: [:index, :show]
end
