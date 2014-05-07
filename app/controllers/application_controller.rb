class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :configure_devise_params, if: :devise_controller?
  
  def configure_devise_params
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:remember_me, :name, :email, :password, :password_confirmation, organizations_attributes: [:permalink]) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:remember_me, :email, :password, :password_confirmation) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
  end
  
  def set_organization
    if params[:permalink]
      @org = Organization.where(permalink: params[:permalink]).first
    else
      @org = current_user.organizations.first
    end
    
    set_membership
  end
  
  def set_membership
    @membership = @org.memberships.where(user_id: current_user.id).first
  end
end
