class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :except => [:application_error]

    def after_sign_in_path_for(resource)
      request.env['omniauth.origin'] || root_path
   end
end
