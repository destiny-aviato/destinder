class TeamStat < ApplicationRecord
    serialize :stats_data
    serialize :characters
    validates :display_name, presence: true


    def self.get_elo(membership_id)
        elo = 1200
        
        begin 
        response = Typhoeus.get(
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

    def self.get_activity(username)
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
            @membership_id = membership_data["Response"][0]["membershipId"]
            @real_name =  membership_data["Response"][0]["displayName"]

            get_characters = Typhoeus::Request.new(
                "https://www.bungie.net/Platform/Destiny/#{username.membership_type}/Account/#{@membership_id}/",
                method: :get,
                headers: {"x-api-key" => ENV['API_TOKEN']}
            )


            get_characters.on_complete do |character_response|  
                character_data = JSON.parse(character_response.body)
                #TODO: Making this call again later on for original search - need to cut it down at some point 
                @last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]

                get_recent = Typhoeus::Request.new(
                    "https://www.bungie.net/Platform/Destiny/Stats/ActivityHistory/#{username.membership_type}/#{@membership_id}/#{@last_character}/?mode=TrialsOfOsiris&count=1",
                    method: :get,
                    headers: {"x-api-key" => ENV['API_TOKEN']}
                )

                get_recent.on_complete do |recent_response|
                    recent_data = JSON.parse(recent_response.body)
                    @recent_game = recent_data["Response"]["data"]["activities"][0]["activityDetails"]["instanceId"]
                    @searched_team = recent_data["Response"]["data"]["activities"][0]["values"]["team"]["basic"]["value"]        
                end
                hydra.queue(get_recent)
            end

            hydra.queue(get_characters)

        end
        hydra.queue(get_membership)
        hydra.run

        #get pgcr 
        get_pgcr = Typhoeus.get(
            "https://www.bungie.net/Platform/Destiny/Stats/PostGameCarnageReport/#{@recent_game}/?lc=en",
            headers: {"x-api-key" => ENV['API_TOKEN']}
        )
        pgcr_data = JSON.parse(get_pgcr.body)
        @players = []
        @characters_stats = []
        pgcr_data["Response"]["data"]["entries"].each do |x|
            @players << x
        end

        @players.each do |player|
            team = player["values"]["team"]["basic"]["value"]
            if team != @searched_team
                next
            else
                player_name = player["player"]["destinyUserInfo"]["displayName"]
                player_membership_id = player["player"]["destinyUserInfo"]["membershipId"]
                player_character = player["characterId"]

                #get player characters 
                get_player_characters = Typhoeus::Request.new(
                    "https://www.bungie.net/Platform/Destiny/#{username.membership_type}/Account/#{player_membership_id}/",
                    method: :get,
                    headers: {"x-api-key" => ENV['API_TOKEN']}
                )

                get_player_characters.on_complete do |character_response|  
                    character_data = JSON.parse(character_response.body)
                    last_character = character_data["Response"]["data"]["characters"][0]
                    
                    character_id =  last_character["characterBase"]["characterId"]
                    character_type = last_character["characterBase"]["classType"]
                    light_level = last_character["characterBase"]["powerLevel"]
                    grimoire = last_character["characterBase"]["grimoireScore"]
                    stat_dicipline = last_character["characterBase"]["stats"]["STAT_DISCIPLINE"]["value"]
                    stat_intellect = last_character["characterBase"]["stats"]["STAT_INTELLECT"]["value"]
                    stat_strength = last_character["characterBase"]["stats"]["STAT_STRENGTH"]["value"]
                    stat_armor = last_character["characterBase"]["stats"]["STAT_ARMOR"]["value"]
                    stat_agility = last_character["characterBase"]["stats"]["STAT_AGILITY"]["value"]
                    stat_recovery = last_character["characterBase"]["stats"]["STAT_RECOVERY"]["value"]
                    inventory = last_character["characterBase"]["peerView"]["equipment"]
                    @items = Hash.new


                    item_type = {
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
                    
                    @items["Emblem Background"] = "https://www.bungie.net#{last_character['backgroundPath']}" #emblem background
    
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
                            @items[item_type[index]] = item
                        end
                        
                        hydra.queue(get_items)
                    end

                    get_trials_stats = Typhoeus::Request.new(
                        "https://www.bungie.net/Platform/Destiny/Stats/#{username.membership_type}/#{player_membership_id}/#{character_id}/?modes=14",
                        method: :get,
                        headers: {"x-api-key" => ENV['API_TOKEN']}
                    )

                    get_trials_stats.on_complete do |stat_response|                     
                        stat_data = JSON.parse(stat_response.body)
                        elo = get_elo(player_membership_id)
                        kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
                        deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
                        assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 
        
                        kd = (kills / deaths).round(2)
                        kad = ((kills + assists) / deaths).round(2)

                        @stats = {
                            "Kills" => kills.round, 
                            "Deaths" => deaths.round,
                            "Assists" => assists.round,
                            "K/D Ratio" => kd,
                            "KA/D Ratio" => kad,
                            "Intellect" => stat_intellect,
                            "Discipline" => stat_dicipline,
                            "Strength" => stat_strength,
                            "ELO" => elo,
                            "Armor" => stat_armor,
                            "Agility" => stat_agility,
                            "Recovery" => stat_recovery,
                            "Light Level" => light_level,
                            "Grimoire" => grimoire
                        }
                        
                        @profile = User.where('lower(display_name) = ?', player_name.downcase).first
                        badges = @profile.nil? ? "N/A" : @profile.badges 
                       
                        @team << {"Player Name" => player_name, "Character Type" => character_type, "Character Stats" => @stats, "Character Items" => @items, "Badges" => badges} 
                    end
                    hydra.queue(get_trials_stats)

                end
                hydra.queue(get_player_characters)

            end
            hydra.run
        end
        index = @team.index{|x| x["Player Name"].downcase == username.display_name.downcase}
        if index != 0
            @team[0], @team[index] = @team[index], @team[0]
        end
       @team
    end


end
