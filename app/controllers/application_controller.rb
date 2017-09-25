class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :record_user_activity

  def after_sign_in_path_for(_resource)
    request.env['omniauth.origin'] || root_path
  end

  private

  def record_user_activity
    current_user.touch :last_active_at if current_user
  end
end
