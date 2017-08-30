class User < ApplicationRecord
  has_merit

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :microposts, dependent: :destroy
  acts_as_voter    
  acts_as_voteable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
         :omniauthable, :omniauth_providers => [:bungie]

  def email_required?
    false
  end
  
  def password_required?
    false
  end


  def self.get_membership_id(username)
    begin
        user = username.include?(" ") ? username.gsub(/\s/,'%20') : username
        response = Typhoeus.get(
            "https://www.bungie.net/d1/Platform/Destiny/SearchDestinyPlayer/2/#{user}/",
            headers: {"x-api-key" => ENV['API_TOKEN']}
        )
      
        data = JSON.parse(response.body)

        if data["Response"][0].nil?
            "1"
        else 
            "2"
        end
    rescue
    end
  end

  def self.search(search)
    search.strip!
    search.downcase!
    where("LOWER(display_name) LIKE ?", "%#{search}%") 
  end

  def get_elo(membership_id)
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

def get_recent_games(username, character_id)
    games = []
    get_recent_games = Typhoeus.get(
        "https://www.bungie.net/d1/Platform/Destiny/Stats/ActivityHistory/#{username.api_membership_type}/#{username.api_membership_id}/#{character_id}/?mode=14&count=15&lc=en",
        headers: {"x-api-key" => ENV['API_TOKEN']}
        )
        
    game_data = JSON.parse(get_recent_games.body)
    game_data["Response"]["data"]["activities"].each do |game|
        game_kills = game["values"]["kills"]["basic"]["value"]
        game_deaths = game["values"]["deaths"]["basic"]["value"]
        game_kd = game["values"]["killsDeathsRatio"]["basic"]["displayValue"]
        game_kad = game["values"]["killsDeathsAssists"]["basic"]["displayValue"]
        game_standing = game["values"]["standing"]["basic"]["value"]
        
        game_info = {
            "kills" => game_kills,
            "deaths" => game_deaths,
            "kd_ratio" => game_kd,
            "kad_ratio" => game_kad,
            "standing" => game_standing
        }

        games << game_info
    end
    games

  end

#   def get_item(item_hash)
#     response = Typhoeus.get(
#         "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{item_hash}/",
#          headers: {"x-api-key" => ENV['API_TOKEN']}
#     )

#     data = JSON.parse(response.body)
#     icon = "https://www.bungie.net#{data["Response"]["data"]["inventoryItem"]["icon"]}"
#     name = data["Response"]["data"]["inventoryItem"]["itemName"]
#     item = {
#         "Item Icon" => icon,
#         "Item Name" => name
#     }
#     item
#   end
  def get_raids_stats(username)
    username.display_name.strip!
    
    user = username.display_name.include?(" ") ? username.display_name.gsub(/\s/,'%20') : username.display_name
        
    hydra = Typhoeus::Hydra.hydra

    get_characters = Typhoeus::Request.new(
        "https://www.bungie.net/d1/Platform/Destiny/#{username.api_membership_type}/Account/#{username.api_membership_id}/",
        method: :get,
        headers: {"x-api-key" => ENV['API_TOKEN']}
    )
    
    hydra.queue(get_characters)
    hydra.run
    @characters_stats
  end
  
  def get_trials_stats(username)
        username.display_name.strip!

        user = username.display_name.include?(" ") ? username.display_name.gsub(/\s/,'%20') : username.display_name
    
        hydra = Typhoeus::Hydra.hydra
        
        elo = get_elo(username.api_membership_id)
            
        get_characters = Typhoeus::Request.new(
            "https://www.bungie.net/d1/Platform/Destiny/#{username.api_membership_type}/Account/#{username.api_membership_id}/",
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
                    17 => "Emblem Background",
                    18 => "Emblem"
                }
                
                items["Emblem Background"] = "https://www.bungie.net#{x['backgroundPath']}" #emblem background
                items["Emblem"] = "https://www.bungie.net/#{x['emblemPath']}"

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
                    "https://www.bungie.net/d1/Platform/Destiny/Stats/#{username.api_membership_type}/#{username.api_membership_id}/#{character_id}/?modes=14",
                    method: :get,
                    headers: {"x-api-key" => ENV['API_TOKEN']}
                    )
    
                get_trials_stats.on_complete do |stat_response|                     
                    stat_data = JSON.parse(stat_response.body)
                    

                    if stat_data["Response"]["trialsOfOsiris"] != {}                     
                        kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
                        deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
                        assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 
                        games_played = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesEntered"]["basic"]["value"] 
                        games_won = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesWon"]["basic"]["value"]
                        avg_life_span = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageLifespan"]["basic"]["displayValue"]
                        auto_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsAutoRifle"]["basic"]["value"]
                        fusion_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsFusionRifle"]["basic"]["value"]
                        hand_cannon = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsHandCannon"]["basic"]["value"]
                        machine_gun = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsMachinegun"]["basic"]["value"]
                        pulse_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsPulseRifle"]["basic"]["value"]
                        rocket_launcher = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsRocketLauncher"]["basic"]["value"]
                        scout_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsScoutRifle"]["basic"]["value"]
                        shotgun = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsShotgun"]["basic"]["value"]
                        sniper = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSniper"]["basic"]["value"]
                        sub_machine_gun = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSubmachinegun"]["basic"]["value"]
                        side_arm = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSideArm"]["basic"]["value"]
                        sword = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSword"]["basic"]["value"]
                        melee = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsMelee"]["basic"]["value"]
                        grenades = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsGrenade"]["basic"]["value"]
                        super_kills =  stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSuper"]["basic"]["value"]
                        ability_kills =  stat_data["Response"]["trialsOfOsiris"]["allTime"]["abilityKills"]["basic"]["value"]
                        longest_spree = stat_data["Response"]["trialsOfOsiris"]["allTime"]["longestKillSpree"]["basic"]["value"]
                        weapon_best_type = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponBestType"]["basic"]["displayValue"]
                        longest_life = stat_data["Response"]["trialsOfOsiris"]["allTime"]["longestSingleLife"]["basic"]["displayValue"]
                        total_activity_time = stat_data["Response"]["trialsOfOsiris"]["allTime"]["totalActivityDurationSeconds"]["basic"]["displayValue"]
                        orbs_dropped = stat_data["Response"]["trialsOfOsiris"]["allTime"]["orbsDropped"]["basic"]["displayValue"]
                        res_received = stat_data["Response"]["trialsOfOsiris"]["allTime"]["resurrectionsReceived"]["basic"]["displayValue"]
                        res_performed = stat_data["Response"]["trialsOfOsiris"]["allTime"]["resurrectionsPerformed"]["basic"]["displayValue"]
                        precision_kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["precisionKills"]["basic"]["displayValue"]
                        average_lifespan = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageLifespan"]["basic"]["displayValue"]                        
                        avg_kill_distance = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageKillDistance"]["basic"]["displayValue"]                        
                        avg_death_distance = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageDeathDistance"]["basic"]["value"]
                        win_rate = (((games_won / games_played).round(2)) * 100).round
        
                        kd = (kills / deaths).round(2)
                        kad = ((kills + assists) / deaths).round(2)
                    else 
                        kills = 0 
                        deaths = 0
                        assists = 0 
                        avg_life_span = 0
                        auto_rifle = 0
                        fusion_rifle = 0
                        hand_cannon = 0
                        machine_gun = 0
                        pulse_rifle = 0
                        rocket_launcher = 0
                        scout_rifle = 0
                        shotgun = 0
                        sniper = 0
                        sub_machine_gun = 0
                        side_arm = 0
                        sword = 0
                        melee = 0
                        grenades = 0
                        super_kills =  0
                        ability_kills =  0
                        longest_spree = 0
                        weapon_best_type = 0
                        longest_life = 0
                        orbs_dropped = 0
                        res_received = 0
                        res_performed = 0
                        precision_kills = 0
                        average_lifespan = 0
                        avg_kill_distance = 0
                        avg_death_distance = 0     
                        games_played = 0
                        games_won = 0
                        kd = 0 
                        kad = 0 
                        win_rate = 0                        
                    end

                    kill_stats = {
                        "Average Life Span" => avg_life_span,
                        "Auto Rifle" => auto_rifle,
                        "Fusion Rifle" => fusion_rifle, 
                        "Hand Cannon" => hand_cannon,
                        "Machine Gun" => machine_gun,
                        "Pulse Rifle" => pulse_rifle,
                        "Rocket Launcher" => rocket_launcher,
                        "Scout Rifle" => scout_rifle,
                        "Shotgun" => shotgun,
                        "Sniper" => sniper,
                        "Sub Machine Gun" => sub_machine_gun,
                        "Side Arm" => side_arm,
                        "Sword" => sword,
                        "Melee" => melee,
                        "Grenades" => grenades,
                        "Super" => super_kills,
                        "Ability" => ability_kills,
                        "Longest Spree" => longest_spree,
                        "Best Weapon Type" => weapon_best_type,
                        "Longest Life" => longest_life,
                        "Orbs Dropped" => orbs_dropped,
                        "Revives Received" => res_received,
                        "Revives Performed" => res_performed,
                        "Precision Kills" => precision_kills,
                        "Average Lifespan" => average_lifespan,
                        "Average Kill Distance" => avg_kill_distance,
                        "Average Death Distance" => avg_death_distance
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
                        "ELO" => elo,
                        "games_won" => games_won,
                        "games_lost" => (games_played - games_won),
                        "Win Rate" => win_rate,
                        "Armor" => stat_armor,
                        "Agility" => stat_agility,
                        "Recovery" => stat_recovery,
                        "Light Level" => light_level,
                        "Grimoire" => grimoire,
                        "Kill Stats" => kill_stats
                    }

                    @characters_stats << {"Character Type" => character_type, "Character Stats" => @stats, "Character Items" => items, "recent_games" => get_recent_games(username, character_id)}
                    
                end
                    
                hydra.queue(get_trials_stats)
                
            end
        end

        
        hydra.queue(get_characters)
        hydra.run
        @characters_stats
        
    end


  def self.from_omniauth(auth)
     where(provider: auth.provider, :uid => auth.uid).first_or_create do |user|
      user.membership_id = auth.info.membership_id
      user.unique_name   = auth.info.unique_name
      user.profile_picture  = "https://www.bungie.net/#{auth.extra.bungieNetUser["profilePicturePath"]}"
      user.about = auth.extra.bungieNetUser["about"]
      user.api_membership_id = auth.extra.destinyMemberships[0]["membershipId"]
      user.api_membership_type = auth.extra.destinyMemberships[0]["membershipType"]
      user.display_name = auth.extra.destinyMemberships[0]['displayName']
  end
end

end
