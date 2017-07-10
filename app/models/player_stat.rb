class PlayerStat < ApplicationRecord
    serialize :stats_data
    serialize :characters
    validates :display_name, presence: true

    def self.collect_data(user, membership_type)
        
        user.downcase!
        
        if user.include? " "
            user.gsub!(/\s/,'%20')
        end


        response = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        data = JSON.parse(response.body)

        membership_id = data["Response"][0]["membershipId"]
        real_name =  data["Response"][0]["displayName"]

        response2 = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/#{membership_type}/Account/#{membership_id}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        data2 = JSON.parse(response2.body)
        characters =[]
        data2["Response"]["data"]["characters"].each do |x| 
            characters << x["characterBase"]["classType"]
            
         end   

        # return [JSON.pretty_generate(data2), real_name]
        return [data2, characters, real_name]
    end

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

    def self.get_trials_stats(user, membership_type)
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


    
end
