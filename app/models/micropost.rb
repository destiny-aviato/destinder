class Micropost < ApplicationRecord
  
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :game_type, presence: true
  serialize :user_stats


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



  def self.get_trials_stats(user)
    cache_key = "postsStats|#{user.id}|#{user.updated_at}"
    Rails.cache.fetch("#{cache_key}/trials_stats", expires_in: 2.minutes) do
        
      get_characters = RestClient.get(
          "http://www.bungie.net/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}",
          headers={"x-api-key" => ENV['API_TOKEN']}
      )

      character_data = JSON.parse(get_characters.body)
      last_character = character_data["Response"]["data"]["characters"][0]
      characters_stats = []
      

        character_id =  last_character["characterBase"]["characterId"]
        character_type = last_character["characterBase"]["classType"]
        begin 
          get_trials_stats = RestClient.get(
                      "https://www.bungie.net/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{character_id}/?modes=14",
                      headers={"x-api-key" => ENV['API_TOKEN']}
                  )   
                  
          stat_data = JSON.parse(get_trials_stats.body)

          kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
          deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
          assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 
          games_played = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesEntered"]["basic"]["value"] 
          games_won = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesWon"]["basic"]["value"]
          avg_life_span = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageLifespan"]["basic"]["displayValue"]

          win_rate = (((games_won / games_played).round(2)) * 100).round

          kd = (kills / deaths).round(2)
          kad = ((kills + assists) / deaths).round(2)
          
          stats = {
              "K/D Ratio" => kd,
              "KA/D Ratio" => kad,
              "ELO" => get_elo(user.api_membership_id),
              "Win Rate" => win_rate
          }
        rescue StandardError => e 
          stats = {
            "K/D Ratio" => "-",
            "KA/D Ratio" => "-",
            "ELO" => "-",
            "Win Rate" => "-"
        }
        end


        characters_stats << {"Character Type" => character_type, "Character Stats" => stats}
        characters_stats = Hash[*characters_stats]
      
        characters_stats
      end
  end
end
