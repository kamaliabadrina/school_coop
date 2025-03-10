class ProfilesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_profile
  
    def show
    end
  
    def edit
    end
  
    def update
      if @profile.update(profile_params)
        redirect_to profile_path, notice: "Profile updated successfully."
      else
        render :edit
      end
    end
  
    private
  
    def set_profile
      @profile = current_user.profile
    end
  
    def profile_params
      params.require(:profile).permit(:full_name, :phone_number, :address)
    end
  end