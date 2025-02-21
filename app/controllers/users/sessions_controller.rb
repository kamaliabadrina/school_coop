class Users::SessionsController < Devise::SessionsController
    def destroy
      Rails.logger.info "Logging out user"
      super do
        flash[:notice] = "Successfully logged out."
        redirect_to new_user_session_path and return
      end
    end
  end
  