class MicropostsController < ApplicationController
    before_action :correct_user, only: :destroy

    def index
        @microposts = Micropost.where(:platform => current_user.api_membership_type).paginate(page: params[:page], per_page: 25)
        filtering_params(params).each do |key, value|
          @microposts = @microposts.public_send(key, value) if value.present?
        end
        @micropost = current_user.microposts.build 

        respond_to do |format|
            format.html { }
            format.js { }
        end
        
    end

    def create

        @micropost = current_user.microposts.build(micropost_params)
        case @micropost.game_type
        when "Trials of Osiris" 
            @micropost.raid_difficulty = ""
            @micropost.user_stats = get_stats(current_user, "too", @micropost.raid_difficulty, @micropost.character_choice)            
        when "Wrath of the Machine"
            @micropost.user_stats = get_stats(current_user, "wrath", @micropost.raid_difficulty, @micropost.character_choice)
        when "King's Fall"
            @micropost.user_stats = get_stats(current_user, "kings", @micropost.raid_difficulty, @micropost.character_choice)
        when "Crota's End"
            @micropost.user_stats = get_stats(current_user, "crota", @micropost.raid_difficulty, @micropost.character_choice)
        when "Vault of Glass"
            @micropost.user_stats = get_stats(current_user, "vog", @micropost.raid_difficulty, @micropost.character_choice)
        when "Nightfall"
            @micropost.raid_difficulty = ""
            @micropost.user_stats = get_stats(current_user, "night", @micropost.raid_difficulty, @micropost.character_choice)            
        end

        @micropost.platform = current_user.api_membership_type
        if @micropost.save
            respond_to do |format|
                format.html { redirect_to microposts_path }
                format.js { }
            end
        else
            respond_to do |format|
                format.js { render :js => "Materialize.toast('Whoops! Your post is too long.', 4000); " }
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

    def get_stats(user, mode, diff, char_id)
        begin
            case mode
            when "too"  
                Micropost.get_trials_stats(user, char_id)
            when "wrath"
                Micropost.get_raid_stats(user, "wrath", diff, char_id)
            when "kings"
                Micropost.get_raid_stats(user, "kings", diff, char_id)
            when "crota"
                Micropost.get_raid_stats(user, "crota", diff, char_id)
            when "vog"
                Micropost.get_raid_stats(user, "vog", diff, char_id)
            when "night"
                Micropost.get_nightfall_stats(user, char_id)
            end

        rescue NoMethodError => e 
            # redirect_to request.referrer || root_url
            redirect_to root_url
            flash[:error] = "Error: #{e}"
        end
    end
    helper_method :get_stats

    def get_characters(user)
        character_races = {0 => "Titan", 1 => "Hunter", 2 => "Warlock"} 
        
        get_characters = Typhoeus.get(
            "https://www.bungie.net/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
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


    private

    def micropost_params
      params.require(:micropost).permit(:content, :game_type, :user_stats, :platform, :raid_difficulty, :checkpoint, :character_choice)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

    def filtering_params(params)
        params.slice(:game_type, :raid_difficulty, :platform)
      end
end
