class UsersController < ApplicationController
    
  def show
    if params[:id]
        @user = User.find(params[:id])
    else
        @user = current_user
    end 
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def upvote
    begin
      if params[:voter]
        voteable = User.find_by(:id => params[:voter])
        current_user.vote_for(voteable)
        redirect_to request.referrer || root_url
        flash[:notice] = "Vote Cast"
      end
    rescue StandardError => e 
      redirect_to request.referrer || root_url
      flash[:notice] = "Sorry, there was an issue: #{e}"
    end
  end

  def downvote
    begin
      if params[:voter]
        voteable = User.find_by(:id => params[:voter])
        current_user.vote_against(voteable)
        redirect_to request.referrer || root_url
        flash[:notice] = "Vote Cast"
      end
    rescue StandardError => e 
      redirect_to request.referrer || root_url
      flash[:notice] = "Sorry, there was an issue: #{e}"
    end
  end

  def unvote
    begin
      if params[:voter]
        voteable = User.find_by(:id => params[:voter])
        current_user.unvote_for(voteable)
        redirect_to request.referrer || root_url
        flash[:notice] = "Vote Removed"
      end
    rescue StandardError => e 
      redirect_to request.referrer || root_url
      flash[:notice] = "Sorry, there was an issue: #{e}"
    end
  end

  def index
    @users = User.all
    if params[:search]
      params[:search] = params[:search][0]
      begin
        @users = User.search(params[:search])
        redirect_to user_path(@users.first.id)
      rescue NoMethodError
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
          Rails.cache.fetch("user_trials_stats", expires_in: 2.minutes) do
            return @user.get_trials_stats(@user)
          end
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