class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :game_type, presence: true


    def self.get_elo(membership_id)
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



  def self.get_trials_stats(username, membership_type)
    username.strip!
    user = username.include?(" ") ? username.gsub(/\s/,'%20') : username

    get_player = RestClient.get(
        "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}",
         headers={"x-api-key" => ENV['API_TOKEN']}
    )

    player_data = JSON.parse(get_player.body)

    membership_id = player_data["Response"][0]["membershipId"]

    get_characters = RestClient.get(
        "http://www.bungie.net/Platform/Destiny/#{membership_type}/Account/#{membership_id}",
         headers={"x-api-key" => ENV['API_TOKEN']}
    )

    character_data = JSON.parse(get_characters.body)
    last_character = character_data["Response"]["data"]["characters"][0]
    characters_stats = []
    

      character_id =  last_character["characterBase"]["characterId"]
      character_type = last_character["characterBase"]["classType"]

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
          "K/D Ratio" => kd,
          "KA/D Ratio" => kad,
          "ELO" => get_elo(membership_id)
      }


      characters_stats << {"Character Type" => character_type, "Character Stats" => stats}

    
      characters_stats

  end
end
