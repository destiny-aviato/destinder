class PlayerStat < ApplicationRecord
    serialize :stats_data
    serialize :characters
    validates :display_name, presence: true

    def self.collect_data(username, membership_type)
        
        username.downcase!
        
        user = username.include?(" ") ? username.gsub(/\s/,'%20') : username


        response = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}/",
             headers: {"x-api-key" => ENV['API_TOKEN']}
        )

        data = JSON.parse(response.body)

        membership_id = data["Response"][0]["membershipId"]
        real_name =  data["Response"][0]["displayName"]

        response2 = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/#{membership_type}/Account/#{membership_id}/",
             headers: {"x-api-key" => ENV['API_TOKEN']}
        )

        data2 = JSON.parse(response2.body)
        characters =[]
        data2["Response"]["data"]["characters"].each do |x| 
            characters << x["characterBase"]["classType"]
            
         end   

        # return [JSON.pretty_generate(data2), real_name]
        return [data2, characters, real_name]
    end

    def self.get_item(item_hash)
        response = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{item_hash}/",
             headers: {"x-api-key" => ENV['API_TOKEN']}
        )
    
        data = JSON.parse(response.body)
        icon = "https://www.bungie.net#{data["Response"]["data"]["inventoryItem"]["icon"]}"
        name = data["Response"]["data"]["inventoryItem"]["itemName"]
        item = {
            "Item Icon" => icon,
            "Item Name" => name
    
        }
        item
      end

      def self.get_elo(membership_id)
        elo = 1200
        rank = 0
        
        begin 
        response = Typhoeus.get(
                "https://api.guardian.gg/elo/#{membership_id}"
            )
          
        data = JSON.parse(response.body)
  
        data.each do |x| 
          if x["mode"] == 14
            elo = x["elo"]
            rank = x["rank"]
            break
          end
        end
      rescue StandardError => e
        puts e 
      end
  
      {"ELO" => elo.round, "Rank" => rank.round}
      
    end

    def self.get_trials_stats(username, membership_type)
        username.strip!
        user = username.include?(" ") ? username.gsub(/\s/,'%20') : username
        
        get_player = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}/",
             headers: {"x-api-key" => ENV['API_TOKEN']}
        )

        player_data = JSON.parse(get_player.body)

        membership_id = player_data["Response"][0]["membershipId"]
        # real_name =  player_data["Response"][0]["displayName"]

        hydra = Typhoeus::Hydra.hydra
        
        elo = get_elo(membership_id)
         
        
        get_characters = Typhoeus::Request.new(
            "https://www.bungie.net/d1/Platform/Destiny/#{membership_type}/Account/#{membership_id}/",
            method: :get,
            headers: {"x-api-key" => ENV['API_TOKEN']}
        )
    

        get_characters.on_complete do |character_response|  
            character_data = JSON.parse(character_response.body)
            last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]
            characters = []
            @characters_stats = []
            character_data["Response"]["data"]["characters"].each do |x|
                characters << x
            end

            characters.each do |x| 
                character_id =  x["characterBase"]["characterId"]
                character_type = x["characterBase"]["classType"]
                light_level = x["characterBase"]["powerLevel"]
                grimoire = x["characterBase"]["grimoireScore"]
                stat_dicipline = x["characterBase"]["stats"]["STAT_DISCIPLINE"]["value"]
                stat_intellect = x["characterBase"]["stats"]["STAT_INTELLECT"]["value"]
                stat_strength = x["characterBase"]["stats"]["STAT_STRENGTH"]["value"]
                stat_armor = x["characterBase"]["stats"]["STAT_ARMOR"]["value"]
                stat_agility = x["characterBase"]["stats"]["STAT_AGILITY"]["value"]
                stat_recovery = x["characterBase"]["stats"]["STAT_RECOVERY"]["value"]
                inventory = x["characterBase"]["peerView"]["equipment"]
                items = Hash.new
    
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
                
                items["Emblem Background"] = "https://www.bungie.net#{x['backgroundPath']}" #emblem background
                
                inventory.each_with_index do |item, index|
    
                    get_items = Typhoeus::Request.new(
                        "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{item["itemHash"]}/",
                        method: :get,
                        headers: {"x-api-key" => ENV['API_TOKEN']}
                        )
                
    
                    get_items.on_complete do |item_response|                     
                        item_data = JSON.parse(item_response.body)
                        icon = "https://www.bungie.net#{item_data["Response"]["data"]["inventoryItem"]["icon"]}"
                        name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
                        tier = item_data["Response"]["data"]["inventoryItem"]["tierTypeName"]
                        type = item_data["Response"]["data"]["inventoryItem"]["itemTypeName"]
                        item = {
                            "Item Icon" => icon,
                            "Item Name" => name,
                            "Item Tier" => tier,
                            "Item Type" => type
                        }                        
                        items[item_type[index]] = item
                    end
                    
                    hydra.queue(get_items)
                    
                end
                
    
                get_trials_stats = Typhoeus::Request.new(
                    "https://www.bungie.net/d1/Platform/Destiny/Stats/#{membership_type}/#{membership_id}/#{character_id}/?modes=14",
                    method: :get,
                    headers: {"x-api-key" => ENV['API_TOKEN']}
                    )
    
                get_trials_stats.on_complete do |stat_response|                     
                    stat_data = JSON.parse(stat_response.body)
                    
                    if stat_data["Response"]["trialsOfOsiris"] != {}                     
                        kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
                        deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
                        assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 
        
                        kd = (kills / deaths).round(2)
                        kad = ((kills + assists) / deaths).round(2)
                    else 
                        kills = 0 
                        deaths = 0
                        assists = 0 
        
                        kd = 0 
                        kad = 0 
                    end
    
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

                    @characters_stats << {"Character Type" => character_type, "Character Stats" => @stats, "Character Items" => items}
                    
                end
                    
                hydra.queue(get_trials_stats)
                
            end
        end

        
        hydra.queue(get_characters)
        hydra.run
        @characters_stats

    end
end
