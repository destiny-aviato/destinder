class TeamStat < ApplicationRecord
    serialize :stats_data
    serialize :characters
    validates :display_name, presence: true

    

    def self.get_recent_activity(username)
        username.display_name.strip!
        
        user = username.display_name.include?(" ") ? username.display_name.gsub(/\s/,'%20') : username.display_name
    
        hydra = Typhoeus::Hydra.hydra
        @team = []

        get_membership = Typhoeus::Request.new(
            "https://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{username.membership_type}/#{user}/",
            method: :get,
            headers: {"x-api-key" => ENV['API_TOKEN']}
        )

        get_membership.on_complete do |membership_response|  
            membership_data = JSON.parse(membership_response.body)
            
            membership_id = membership_data["Response"][0]["membershipId"]
            real_name =  membership_data["Response"][0]["displayName"]

            get_characters = Typhoeus::Request.new(
                "https://www.bungie.net/Platform/Destiny/#{username.membership_type}/Account/#{membership_id}/",
                method: :get,
                headers: {"x-api-key" => ENV['API_TOKEN']}
            )
        
           

            get_characters.on_complete do |character_response|  
                character_data = JSON.parse(character_response.body)
                last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]

                get_recent = Typhoeus::Request.new(
                    "https://www.bungie.net/Platform/Destiny/Stats/ActivityHistory/#{username.membership_type}/#{membership_id}/#{last_character}/?mode=TrialsOfOsiris&count=1",
                    method: :get,
                    headers: {"x-api-key" => ENV['API_TOKEN']}
                )

                get_recent.on_complete do |recent_response|
                    recent_data = JSON.parse(recent_response.body)
                    recent_game = recent_data["Response"]["data"]["activities"][0]["activityDetails"]["instanceId"]

                    get_pgcr = Typhoeus::Request.new(
                        "https://www.bungie.net/Platform/Destiny/Stats/PostGameCarnageReport/#{recent_game}/?lc=en",
                        method: :get,
                        headers: {"x-api-key" => ENV['API_TOKEN']}
                    )
                    get_pgcr.on_complete do |pgcr_response|
                        pgcr_data = JSON.parse(pgcr_response.body)
                        team = pgcr_data["Response"]["data"]["entries"]
                        team.each_with_index do |player, index|
                            if index > 2
                                break
                            end
                            player_name = player["player"]["destinyUserInfo"]["displayName"]
                            player_character = player["characterId"]
                            @team << {"Player Name" => player_name, "Player Character" => player_character,}
                        end
                        
                    end
                    hydra.queue(get_pgcr)
                end
                hydra.queue(get_recent)
            end 
            hydra.queue(get_characters)
        end

        hydra.queue(get_membership)
        hydra.run

        @team
                
    end
end
