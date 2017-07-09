class UsersController < ApplicationController
    
  def show
    if params[:id]
        @user = User.find(params[:id])
    else
        @user = current_user
    end 
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def get_stats
    begin
      @user.get_stats(@user.display_name, @user.api_membership_type)
     rescue NoMethodError
        redirect_to request.referrer || root_url
        flash[:error] = "Error: Player Not Found!"
    rescue StandardError => e
        redirect_to root_url
        flash[:error] = "Error: #{e}"
    end
  end
  helper_method :get_stats
 
end