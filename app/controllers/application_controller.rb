class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :user_signed_in?, :current_user

  protected

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # サインアップ時のパラメータ許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :skill, :description])
    # サインイン時のパラメータ許可（必要なら）
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name])
    # アカウント編集時のパラメータ許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :skill, :description])
  end
end