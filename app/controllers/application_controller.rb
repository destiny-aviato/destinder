class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :record_user_activity
  before_action :authenticate_user!, :except => [:application_error]

    def after_sign_in_path_for(resource)
      request.env['omniauth.origin'] || root_path
   end

   private
   
     def record_user_activity
       if current_user
         current_user.touch :last_active_at
       end
     end
end
