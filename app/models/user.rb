class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :microposts, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:bungie]

  def email_required?
    false
  end
  
  def password_required?
    false
  end

  def get_elo(membership_id)
      elo = 1200
      
      begin 
      response = RestClient.get(
              "https://api.guardian.gg/elo/#{membership_id}"
          )
        
      data = JSON.parse(response.body)

      data.each do |x| 
        if x["mode"] == 14
          elo = x["elo"]
          break
        end
      end
    rescue StandardError => e
      puts e 
    end

    elo.round
    
  end

  def get_trials_stats(user, membership_type)
        user.downcase!
        
        if user.include? " "
            user.gsub!(/\s/,'%20')
        end


        get_player = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        player_data = JSON.parse(get_player.body)

        membership_id = player_data["Response"][0]["membershipId"]
        real_name =  player_data["Response"][0]["displayName"]

        get_characters = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/#{membership_type}/Account/#{membership_id}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        character_data = JSON.parse(get_characters.body)
        last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]
        characters = []
        characters_stats = []
        character_data["Response"]["data"]["characters"].each do |x|
            characters << x
        end
        
        characters.each do |x| 
            character_id =  x["characterBase"]["characterId"]
            character_type = x["characterBase"]["classType"]
            stat_dicipline = x["characterBase"]["stats"]["STAT_DISCIPLINE"]["value"]
            stat_intellect = x["characterBase"]["stats"]["STAT_INTELLECT"]["value"]
            stat_strength = x["characterBase"]["stats"]["STAT_STRENGTH"]["value"]

            get_trials_stats = RestClient.get(
                        "https://www.bungie.net/Platform/Destiny/Stats/#{membership_type}/#{membership_id}/#{character_id}/?modes=14",
                        headers={"x-api-key" => ENV['API_TOKEN']}
                    )   
                    
            stat_data = JSON.parse(get_trials_stats.body)

            kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
            deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
            assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 

            kd = (kills / deaths).round(2)
            kad = ((kills + assists) / deaths).round(2)

            stats = {
                "Kills" => kills.round, 
                "Deaths" => deaths.round,
                "Assists" => assists.round,
                "K/D Ratio" => kd,
                "KA/D Ratio" => kad,
                "Intellect" => stat_intellect,
                "Discipline" => stat_dicipline,
                "Strength" => stat_strength,
                "ELO" => get_elo(membership_id)
            }

            characters_stats << {"Character Type" => character_type, "Character Stats" => stats}
        end
        
        characters_stats

    end


  def self.from_omniauth(auth)
     where(provider: auth.provider, :uid => auth.uid).first_or_create do |user|
      user.membership_id = auth.info.membership_id
      user.unique_name   = auth.info.unique_name
      user.profile_picture  = "https://www.bungie.net/#{auth.extra.bungieNetUser["profilePicturePath"]}"
      user.about = auth.extra.bungieNetUser["about"]
      user.api_membership_id = auth.extra.destinyMemberships[0]["membershipId"]
      user.api_membership_type = auth.extra.destinyMemberships[0]["membershipType"]

      if auth.extra.bungieNetUser.key?("psnDisplayName")
        user.display_name = auth.extra.bungieNetUser["psnDisplayName"]
      elsif auth.extra.bungieNetUser.key?("xboxDisplayName")
        user.display_name = auth.extra.bungieNetUser["xboxDisplayName"]

      end
      
  end
end

end
