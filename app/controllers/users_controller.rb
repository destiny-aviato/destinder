class UsersController < ApplicationController
  def show
    @user = if params[:id]
              User.find(params[:id])
            else
              current_user
            end
    @microposts = @user.microposts.paginate(page: params[:page])

    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def upvote
    if params[:voter]
      voteable = User.find_by(id: params[:voter])
      current_user.vote_for(voteable)
      redirect_to request.referer || root_url
      flash[:notice] = 'Vote Cast'
    end
  rescue StandardError => e
    redirect_to request.referer || root_url
    flash[:notice] = "Sorry, there was an issue: #{e}"
  end

  def downvote
    if params[:voter]
      voteable = User.find_by(id: params[:voter])
      current_user.vote_against(voteable)
      redirect_to request.referer || root_url
      flash[:notice] = 'Vote Cast'
    end
  rescue StandardError => e
    redirect_to request.referer || root_url
    flash[:notice] = "Sorry, there was an issue: #{e}"
  end

  def unvote
    if params[:voter]
      voteable = User.find_by(id: params[:voter])
      current_user.unvote_for(voteable)
      redirect_to request.referer || root_url
      flash[:notice] = 'Vote Removed'
    end
  rescue StandardError => e
    redirect_to request.referer || root_url
    flash[:notice] = "Sorry, there was an issue: #{e}"
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
        @users = PlayerStat.create(display_name: params[:search], membership_type: membership_type)
        redirect_to player_stat_path(@users)
        flash[:notice] = 'Player profile not found in our system. Here are trials stats for that user.'
      rescue StandardError => e
        redirect_to request.referer || root_url
        flash[:error] = "Error: #{e}"
      end
    else
      redirect_to root_url
      flash[:error] = 'No user name supplied'
    end
  end

  def get_stats(mode)
    case mode
    when 'too'
      begin
        Rails.cache.fetch('user_trials_stats', expires_in: 2.minutes) do
          return @user.get_trials_stats(@user)
        end
      rescue NoMethodError
        return nil
      rescue StandardError => e
        return nil
      end
    when 'raids'
      begin
        return @user.get_raids_stats(@user)
      rescue NoMethodError => e
      end
    end
  rescue NoMethodError
    redirect_to request.referer || root_url
    flash[:error] = 'Error: Player Not Found!'
  rescue StandardError => e
    redirect_to root_url
    flash[:error] = "Error: #{e}"
  end
  helper_method :get_stats

  def get_characters2(_user)
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }

    get_characters = Typhoeus.get(
      # "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      'https://www.bungie.net/Platform/Destiny2/2/Profile/4611686018428389623/?components=Characters',
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    characters = []

    character_data['Response']['characters']['data'].each do |x|
      id = x['characterId']
      subclass_val = x['classType']
      subclass = character_races[subclass_val]
      characters << [subclass, id]
    end

    characters
  end
  helper_method :get_characters2
end
