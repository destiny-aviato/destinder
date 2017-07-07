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


    def self.get_stats(user, membership_type)
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

        get_trials_stats = RestClient.get(
            "https://www.bungie.net/Platform/Destiny/Stats/#{membership_type}/#{membership_id}/#{last_character}/?modes=14",
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
            "KA/D Ratio" => kad
        }


        stats
        # return [JSON.pretty_generate(data2), real_name]
        # return [data2, characters, real_name]

    end
    
end
