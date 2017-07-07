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
    PlayerStat.get_stats(@user.display_name,@user.membership_type)
  end
  helper_method :get_stats
 
end