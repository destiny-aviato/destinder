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
                            player_membership_id = player["player"]["destinyUserInfo"]["membershipId"]
                            player_character = player["characterId"]


                            get_trials_stats = Typhoeus::Request.new(
                                "https://www.bungie.net/Platform/Destiny/Stats/#{username.membership_type}/#{player_membership_id}/#{player_character}/?modes=14",
                                method: :get,
                                headers: {"x-api-key" => ENV['API_TOKEN']}
                                )
                
                            get_trials_stats.on_complete do |stat_response|                     
                                stat_data = JSON.parse(stat_response.body)
                                
                                kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
                                deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
                                assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 
                
                                kd = (kills / deaths).round(2)
                                kad = ((kills + assists) / deaths).round(2)
                
                                
                                # http://www.bungie.net/Platform/Destiny/{membershipType}/Account/{destinyMembershipId}/Character/{characterId}/
                                get_character = Typhoeus::Request.new(
                                    "https://www.bungie.net/Platform/Destiny/#{username.membership_type}/Account/#{player_membership_id}/Character/#{player_character}/",
                                    method: :get,
                                    headers: {"x-api-key" => ENV['API_TOKEN']}
                                    )
                    
                                get_character.on_complete do |character_response|                     
                                    character_response = JSON.parse(character_response.body)
                                    stat_dicipline = character_response["Response"]["data"]["characterBase"]["stats"]["STAT_DISCIPLINE"]["value"]
                                    stat_intellect = character_response["Response"]["data"]["characterBase"]["stats"]["STAT_INTELLECT"]["value"]
                                    stat_strength = character_response["Response"]["data"]["characterBase"]["stats"]["STAT_STRENGTH"]["value"]
                                    stat_armor = character_response["Response"]["data"]["characterBase"]["stats"]["STAT_ARMOR"]["value"]
                                    stat_agility = character_response["Response"]["data"]["characterBase"]["stats"]["STAT_AGILITY"]["value"]
                                    stat_recovery = character_response["Response"]["data"]["characterBase"]["stats"]["STAT_RECOVERY"]["value"]
                                    inventory = character_response["Response"]["data"]["characterBase"]["peerView"]["equipment"]                                   
                                    @items = Hash.new
                                    
                                    @item_type = {
                                        0 => "Subclass",
                                        1 => "Helmet",
                                        2 => "Gauntlets",
                                        3 => "Chest Armor",
                                        4 => "Leg Armor",
                                        5 => "Class Item",
                                        6 => "Primary Weapon",
                                        7 => "Secondary Weapon",
                                        8 => "Heavy Weapon",
                                        9 => "Ship",
                                        10 => "Sparrow",
                                        11 => "Ghost",
                                        12 => "Emblem",
                                        13 => "Shader",
                                        14 => "Emote",
                                        15 => "Horn",
                                        16 => "Artifact",
                                        17 => "Emblem Background"
                                    }
                                    
                                    @stats = {
                                        "Kills" => kills.round, 
                                        "Deaths" => deaths.round,
                                        "Assists" => assists.round,
                                        "K/D Ratio" => kd,
                                        "KA/D Ratio" => kad,
                                        "Intellect" => stat_intellect,
                                        "Discipline" => stat_dicipline,
                                        "Strength" => stat_strength,
                                        "ELO" => "elo",
                                        "Armor" => stat_armor,
                                        "Agility" => stat_agility,
                                        "Recovery" => stat_recovery
                                    }

                                    @items["Emblem Background"] = "https://www.bungie.net#{character_response['Response']['data']['backgroundPath']}" #emblem background
                    
                                    inventory.each_with_index do |item, index|
                        
                                        get_items = Typhoeus::Request.new(
                                            "https://www.bungie.net/platform/Destiny/Manifest/InventoryItem/#{item["itemHash"]}/",
                                            method: :get,
                                            headers: {"x-api-key" => ENV['API_TOKEN']}
                                            )
                                    
                        
                                        get_items.on_complete do |item_response|                     
                                            item_data = JSON.parse(item_response.body)
                                            icon = "https://www.bungie.net#{item_data["Response"]["data"]["inventoryItem"]["icon"]}"
                                            name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
                                            item = {
                                                "Item Icon" => icon,
                                                "Item Name" => name
                                            }
                                            @items[@item_type[index]] = item
                                            puts "test"
                                        end
                                        
                                        hydra.queue(get_items)
                                        
                                    end


                                   

                                    @team << {"Player Name" => player_name, "Character Type" => player_character, "Character Stats" => @stats, "Character Items" => @items}
                                    
                                end 
                                hydra.queue(get_character)
                                
                                
                            end
                            hydra.queue(get_trials_stats)
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
