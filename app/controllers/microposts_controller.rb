class MicropostsController < ApplicationController
    before_action :correct_user, only: :destroy

    def index
        @microposts = Micropost.where(:platform => current_user.api_membership_type).paginate(page: params[:page], per_page: 25)
        filtering_params(params).each do |key, value|
          @microposts = @microposts.public_send(key, value) if value.present?
        end
        @micropost = current_user.microposts.build 
        # flash[:notice] = "Notice: We are in the process of updating things for D2. Your D1 characters will show until we have access to the D2 API. Stay Tuned!"
        respond_to do |format|
            format.html { }
            format.js { }
        end
        
    end

    def create
        
        if Rails.env.production?
            if current_user.microposts.any?                 
                current_user.microposts.destroy_all
            end
        end



        @microposts = Micropost.all.paginate(page: params[:page], per_page: 12)
        @micropost = current_user.microposts.build(micropost_params)
        @micropost.raid_difficulty = "Normal" if @micropost.raid_difficulty.nil?
=begin
        0 - any
        1 - other
        2 - story
        3 - strikes
        4 - nightfall
        5 - crucible playlist
        6 - trials of osiris
        7 - raid 1 
        8 - raid 2
        9 - raid 3
        10 - raid 4 
=end

        if @micropost.destiny_version == "1"
            case @micropost.game_type.to_i
            when 6 
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d1(current_user, 6, @micropost.raid_difficulty, @micropost.character_choice)            
                @micropost.elo = @micropost.user_stats["Character Stats"]["ELO"]["ELO"].to_i
                @micropost.kd = @micropost.user_stats["Character Stats"]["K/D Ratio"].to_f
            when 10
                @micropost.user_stats = get_stats_d1(current_user, 10, @micropost.raid_difficulty, @micropost.character_choice)
            when 9
                @micropost.user_stats = get_stats_d1(current_user, 9, @micropost.raid_difficulty, @micropost.character_choice)
            when 8
                @micropost.user_stats = get_stats_d1(current_user, 8, @micropost.raid_difficulty, @micropost.character_choice)
            when 7
                @micropost.user_stats = get_stats_d1(current_user, 7, @micropost.raid_difficulty, @micropost.character_choice)
            when 4
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d1(current_user, 4, @micropost.raid_difficulty, @micropost.character_choice)
            else 
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d1(current_user, 1, @micropost.raid_difficulty, @micropost.character_choice)         
            end
        else
            case @micropost.game_type.to_i
            when 2 
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d2(current_user, 2, @micropost.raid_difficulty, @micropost.character_choice)            
            when 4
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d2(current_user, 4, @micropost.raid_difficulty, @micropost.character_choice)
            when 3
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d2(current_user, 3, @micropost.raid_difficulty, @micropost.character_choice)
            when 5
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d2(current_user, 5, @micropost.raid_difficulty, @micropost.character_choice)
            when 0
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d2(current_user, 0, @micropost.raid_difficulty, @micropost.character_choice)        
            else 
                @micropost.raid_difficulty = ""
                @micropost.user_stats = get_stats_d2(current_user, 1, @micropost.raid_difficulty, @micropost.character_choice)         
            end
        end
        

        @micropost.platform = current_user.api_membership_type
        

        # TODO: Add logic to handle looking for similar
        if @micropost.save
            respond_to do |format|
                format.html { redirect_to microposts_path }
                format.js { }
            end
        else
            respond_to do |format|
                format.js { render :js => "Materialize.toast('Sorry, something went wrong.', 4000); " }
              end
        end
    end

    def destroy
        @microposts = Micropost.all.paginate(page: params[:page], per_page: 12)
        @micropost.destroy

        respond_to do |format|
            format.html { request.referrer || root_url }
            format.js { }
        end
        
    end

    def get_stats_d1(user, mode, diff, char_id)
        begin
            case mode
            when 6 
                Micropost.get_trials_stats(user, char_id)
            when 10
                Micropost.get_raid_stats(user, "wrath", diff, char_id)
            when 9
                Micropost.get_raid_stats(user, "kings", diff, char_id)
            when 8
                Micropost.get_raid_stats(user, "crota", diff, char_id)
            when 7
                Micropost.get_raid_stats(user, "vog", diff, char_id)
            when 4
                Micropost.get_nightfall_stats(user, char_id)
            else
                Micropost.get_other_stats(user, char_id)
            end

        rescue NoMethodError => e 
            # redirect_to request.referrer || root_url
            redirect_to root_url
            flash[:error] = "Error: #{e}"
        end
    end
    helper_method :get_stats_d1

    def get_stats_d2(user, mode, diff, char_id)
        begin
            Micropost.get_other_stats_d2(user, char_id)
        rescue NoMethodError => e 
            # redirect_to request.referrer || root_url
            redirect_to root_url
            flash[:error] = "Error: #{e}"
        end
    end
    helper_method :get_stats_d2

    def get_characters(user)
        character_races = {0 => "Titan", 1 => "Hunter", 2 => "Warlock"} 
        
        get_characters = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
            headers: {"x-api-key" => ENV['API_TOKEN']}
        )
  
        character_data = JSON.parse(get_characters.body)

        characters = []

        character_data["Response"]["data"]["characters"].each do |x| 
           id =  x['characterBase']['characterId']
           subclass_val =  x['characterBase']['classType']
           subclass = character_races[subclass_val]
           characters << [subclass, id]
        end

        characters
    end 
    helper_method :get_characters

    def get_characters2(user)
        character_races = {0 => "Titan", 1 => "Hunter", 2 => "Warlock"} 
        
        get_characters = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
            headers: {"x-api-key" => ENV['API_TOKEN']}
        )
  
        character_data = JSON.parse(get_characters.body)

        characters = []

        character_data["Response"]["data"]["characters"].each do |x| 
           id =  x['characterBase']['characterId']
           subclass_val =  x['characterBase']['classType']
           subclass = character_races[subclass_val]
           characters << [subclass, id]
        end

        characters
    end 
    helper_method :get_characters2


    private

    def micropost_params
      params.require(:micropost).permit(:content, :game_type, :user_stats, :platform, :raid_difficulty, :checkpoint, :character_choice, :mic_required, :looking_for, :elo_min, :elo_max, :kd_min, :kd_max, :destiny_version)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

    def filtering_params(params)
        params.slice(:game_type, :raid_difficulty, :platform, :looking_for, :mic_required, :elo_min, :elo_max, :kd_min, :kd_max, :destiny_version)
        end
end
