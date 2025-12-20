class ApplicationController < ActionController::Base
  # Deviseのコントローラーを使うときだけ、下の configure_... を実行する
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # 新規登録(sign_up)と、アカウント更新(account_update)の時に、nameとavatarを許可する
    keys = [:name, :avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys: keys)
    devise_parameter_sanitizer.permit(:account_update, keys: keys)
  end
end
