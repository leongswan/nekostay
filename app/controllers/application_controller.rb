class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # 新規登録(sign_up)のときに許可する項目
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role, :image])
    
    # プロフィール編集(account_update)のときに許可する項目
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :role, :image, :profile])
  end
end
