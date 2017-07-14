class UsersController < ApplicationController
    
  def show
    if params[:id]
        @user = User.find(params[:id])
    else
        @user = current_user
    end 
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def index
    @users = User.all
    if params[:search]
      begin
        @users = User.search(params[:search])
        redirect_to user_path(@users.first.id)
      rescue NoMethodError
        redirect_to request.referrer || root_url
        flash[:error] = "Player not found. They probably don't have an account in our system."
      rescue StandardError => e
        redirect_to request.referrer || root_url
        flash[:error] = "Error: #{e}"
      end
    else
      redirect_to root_url
      flash[:error] = "No user name supplied"
    end
  end
  
  def get_stats(mode)
    begin
      case mode
      when "too"
        begin
          @user.get_trials_stats(@user.display_name, @user.api_membership_type)
        rescue NoMethodError
          return nil
        rescue StandardError => e
          return nil
        end
      end
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