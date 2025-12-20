class ApplicationController < ActionController::Base

  def configure_permitted_parameters
    # 新規登録時 (sign_up) に avatar も許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :avatar])

    # 編集時 (account_update) に avatar も許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar])
  end
end
