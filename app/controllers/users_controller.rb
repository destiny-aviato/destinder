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
        # redirect_to create_player_path(params[:search])
        membership_type = User.get_membership_id(params[:search])
        @users = PlayerStat.create(:display_name => params[:search], :membership_type => membership_type)
        redirect_to player_stat_path(@users)
        flash[:notice] = "Player profile not found in our system. Here are trials stats for that user."
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