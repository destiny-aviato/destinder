class HomeController < ApplicationController
    helper_method :get_stats
    
    def index

    end    

    def index2
        # puts "test"
        # @stats = get_stats("too")
    end

    def faq
    end

    def kota
    end

    def kurt
    end
    
    def brian
      puts "test"
      # @stats = get_stats("too")
      @stats = get_trials_stats_d2(User.first)
    end
    
    def brock
      puts "test"
      # @stats = get_trials_stats_d2(User.first)
    end

    def alex
      puts "test"
      # @stats = get_stats("too")
    end

    def application_error
    end

    def site_stats
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

      {"elo" => elo.round, "rank" => rank.round}
      
    end

    def get_elo_d2(membership_type, membership_id)
        elo = 1200
        rank = 0
        
        begin 
        response = Typhoeus.get(
            "https://api.guardian.gg/v2/trials/players/#{membership_type}/#{membership_id}"
        )
        
        data = JSON.parse(response.body)

        elo = data["playerStats"][membership_id.to_s]["elo"]
      rescue StandardError => e
        puts e 
      end

      {"elo" => elo.round, "rank" => rank.round}
      
    end

    def get_trials_stats_d2(username)
      username.display_name.strip!
      
      user = username.display_name.include?(" ") ? username.display_name.gsub(/\s/,'%20') : username.display_name
  
      hydra = Typhoeus::Hydra.hydra
      
      # elo = 1200 #get_elo(username.api_membership_id)
      elo = get_elo_d2(username.api_membership_type, 4611686018439345596)
      # subclasses = {
      #   "3225959819" => "Nightstalker",
      #   "3635991036" => "Gunslinger",
      #   "1334959255" => "Arcstrider",            
      #   "3887892656" => "Voidwalker",
      #   "1751782730" => "Stormcaller",
      #   "3481861797" => "Dawnblade",       
      #   "2958378809" => "Striker",
      #   "3105935002" => "Sunbreaker",
      #   "3382391785" => "Sentinel",      
      #   "2863201134" => "Lost Light",
      #   "2934029575" => "Lost Light",
      #   "1112909340" => "Lost Light"
      # }
      character_races = {0 => "Titan", 1 => "Hunter", 2 => "Warlock"} 
      get_characters = Typhoeus::Request.new(
        # "https://www.bungie.net/Platform/Destiny2/#{username.api_membership_type}/Profile/#{username.api_membership_id}/?components=Characters,205",
        "https://www.bungie.net/Platform/Destiny2/1/Profile/4611686018439345596/?components=Characters,205",
        method: :get,
        headers: {"x-api-key" => ENV['API_TOKEN']}
      )

      get_characters.on_complete do |character_response| 
        character_data = JSON.parse(character_response.body)
        @last_character = character_data["Response"]["characters"]["data"].first
        last_played = @last_character[1]["dateLastPlayed"]
        characters = []
        @characters_stats = []
        character_data["Response"]["characters"]["data"].each do |x|
          characters << x
        end

        characters.each do |x| 
          if Time.parse(x[1]["dateLastPlayed"]) > Time.parse(last_played)
            @last_character = x
          end
          character_id = x[0]
          character_type = x[1]["classType"]
          light_level = x[1]["light"]
          # grimoire = @character["characterBase"]["grimoireScore"]
          background = "https://www.bungie.net#{x[1]['emblemBackgroundPath']}"
          emblem = "https://www.bungie.net#{x[1]['emblemPath']}"
          # subclass_name = character_races[character_type.to_i]
          # inventory = ["Response"]["data"]["characterEquipment"]
          items = Hash.new

          item_types = {
            "1498876634" => "primary_weapon_1",
            "2465295065" => "primary_weapon_2",
            "953998645" => "power_weapon",
            "3448274439" => "helmet",
            "3551918588" => "gauntlets",
            "14239492" => "chest_armor",
            "20886954" => "leg_armor",
            "1585787867" => "class_item",
            # "4023194814" => "shell",
            # "284967655" => "ship",
            "3284755031" => "subclass",
            # "4274335291" => "emblem",
            # "3054419239" => "emote", 
            "1269569095" => "aura"
          } 

          items["emblem_background"] = "https://www.bungie.net#{x[1]['emblemBackgroundPath']}"#emblem background
          items["emblem"] = "https://www.bungie.net#{x[1]['emblemPath']}"

          character_data["Response"]["characterEquipment"]["data"][character_id]["items"].each do |item|
            get_items = Typhoeus::Request.new(
              # "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{item["itemHash"]}/",
              "https://www.bungie.net/Platform/Destiny2/Manifest/DestinyInventoryItemDefinition/#{item["itemHash"]}/",
              method: :get,
              headers: {"x-api-key" => ENV['API_TOKEN']}
            )

            get_items.on_complete do |item_response| 
              item_data = JSON.parse(item_response.body) 
              icon = "https://www.bungie.net#{item_data["Response"]["displayProperties"]["icon"]}"
              name = item_data["Response"]["displayProperties"]["name"]                  
              tier = item_data["Response"]["inventory"]["tierTypeName"]
              type = item_data["Response"]["itemTypeDisplayName"]
              bucket_hash = item_data["Response"]["inventory"]["bucketTypeHash"]
              puts bucket_hash
              
              item = {
                  "item_icon" => icon,
                  "item_name" => name,
                  "item_tier" => tier,
                  "item_type" => type
              }
              if !item_types[bucket_hash.to_s].nil?
                items[item_types[bucket_hash.to_s]] = item
              else 
                next
              end
            end
            
            hydra.queue(get_items)


          end

          get_trials_stats = Typhoeus::Request.new(
            "https://www.bungie.net/Platform/Destiny2/1/Account/4611686018439345596/Character/2305843009260359587/Stats/?modes=39",
            # "https://www.bungie.net/Platform/Destiny2/#{username.api_membership_type}/Account/#{username.api_membership_id}/Character/#{character_id}/Stats/?modes=39",
            method: :get,
            headers: {"x-api-key" => ENV['API_TOKEN']}
          )

          get_trials_stats.on_complete do |stat_response| 
            stat_data = JSON.parse(stat_response.body)
            if stat_data["Response"]["trialsOfOsiris"] != {} 
              stats = stat_data["Response"]["trialsofthenine"]["allTime"]
              # elo = get_elo(user.api_membership_id)
              
              
              # win_rate = stats["winLossRatio"]["basic"]["displayValue"]
              kills = stats["kills"]["basic"]["displayValue"]
              assists = stats["assists"]["basic"]["displayValue"]
              deaths = stats["deaths"]["basic"]["displayValue"]
              average_life_span = stats["averageLifespan"]["basic"]["displayValue"]
              kd_ratio = stats["killsDeathsRatio"]["basic"]["displayValue"]
              games_played = stats["activitiesEntered"]["basic"]["displayValue"]
              games_won = stats["activitiesWon"]["basic"]["value"]
              kad = stats["killsDeathsAssists"]["basic"]["displayValue"]
              kd = stats["killsDeathsRatio"]["basic"]["displayValue"]
              win_rate = ((games_won.to_f / games_played.to_f) * 100).round(1)
              auto_rifle = stats["weaponKillsAutoRifle"]["basic"]["displayValue"]
              fusion_rifle = stats["weaponKillsFusionRifle"]["basic"]["displayValue"] 
              hand_cannon = stats["weaponKillsHandCannon"]["basic"]["displayValue"] 
              machine_gun = stats["weaponKillsMachinegun"]["basic"]["displayValue"]  
              pulse_rifle = stats["weaponKillsPulseRifle"]["basic"]["displayValue"] 
              rocket_launcher = stats["weaponKillsRocketLauncher"]["basic"]["displayValue"] 
              scout_rifle = stats["weaponKillsScoutRifle"]["basic"]["displayValue"] 
              shotgun = stats["weaponKillsShotgun"]["basic"]["displayValue"] 
              sniper = stats["weaponKillsSniper"]["basic"]["displayValue"] 
              sub_machine_gun = stats["weaponKillsSubmachinegun"]["basic"]["displayValue"] 
              side_arm = stats["weaponKillsSideArm"]["basic"]["displayValue"] 
              sword = stats["weaponKillsSword"]["basic"]["displayValue"] 
              # melee = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsMelee"]["basic"]["value"]
              grenades = stats["weaponKillsGrenade"]["basic"]["displayValue"] 
              # super_kills =  stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSuper"]["basic"]["value"]
              ability_kills =  stats["weaponKillsAbility"]["basic"]["displayValue"] 
              grenade_launcher =  stats["weaponKillsGrenadeLauncher"]["basic"]["displayValue"] 
              longest_spree = stats["longestKillSpree"]["basic"]["displayValue"] 
              weapon_best_type = stats["weaponBestType"]["basic"]["displayValue"]
              longest_life = stats["longestSingleLife"]["basic"]["displayValue"]
              total_activity_time = stats["totalActivityDurationSeconds"]["basic"]["displayValue"]
              orbs_dropped = stats["orbsDropped"]["basic"]["displayValue"]
              res_received = stats["resurrectionsReceived"]["basic"]["displayValue"]
              res_performed = stats["resurrectionsPerformed"]["basic"]["displayValue"]
              precision_kills = stats["precisionKills"]["basic"]["displayValue"]
              average_lifespan = stats["averageLifespan"]["basic"]["displayValue"]                        
              avg_kill_distance = stats["averageKillDistance"]["basic"]["displayValue"]                        
              avg_death_distance = stats["averageDeathDistance"]["basic"]["displayValue"]
              best_single_game_kills = stats["bestSingleGameKills"]["basic"]["displayValue"]
            else
              kills = 0
              assists = 0
              deaths = 0
              average_life_span = 0
              kd_ratio = 0
              games_played = 0
              games_won = 0
              kad = 0
              kd = 0
              win_rate = 0
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
              # melee = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsMelee"]["basic"]["value"]
              grenades = 0
              # super_kills =  stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSuper"]["basic"]["value"]
              ability_kills =  0
              grenade_launcher =  0
              longest_spree = 0
              weapon_best_type = 0
              longest_life = 0
              total_activity_time = 0
              orbs_dropped = 0
              res_received = 0
              res_performed = 0
              precision_kills = 0
              average_life_span = 0
              avg_kill_distance = 0
              avg_death_distance = 0
              best_single_game_kills = 0
            end

            kill_stats = {
              "auto_rifle" => auto_rifle,
              "fusion_rifle" => fusion_rifle, 
              "hand_cannon" => hand_cannon,
              "machine_gun" => machine_gun,
              "pulse_rifle" => pulse_rifle,
              "rocket_launcher" => rocket_launcher,
              "scout_rifle" => scout_rifle,
              "shotgun" => shotgun,
              "sniper" => sniper,
              "sub_machine_gun" => sub_machine_gun,
              "side_arm" => side_arm,
              "sword" => sword,
              # "melee" => melee,
              "grenades" => grenades,
              "grenade_launcher" => grenade_launcher,
              # "Super" => super_kills,
              "ability" => ability_kills,
              "longest_spree" => longest_spree,
              "best_weapon_type" => weapon_best_type,
              "longest_life" => longest_life,
              "orbs_dropped" => orbs_dropped,
              "revives_received" => res_received,
              "revives_performed" => res_performed,
              "precision_kills" => precision_kills,
              "average_life_span" => average_life_span,            
              "average_kill_distance" => avg_kill_distance,
              "average_death_distance" => avg_death_distance,
              "total_activity_time" => total_activity_time,
              "best_single_game_kills" => best_single_game_kills   
            }

            @stats = {
              "light_level" => light_level,
              "grimoire" => "0",
              "background" => background,
              "emblem" => emblem,
              "subclass_icon" => "" ,
              "subclass_name" => @subclass_name,
              "kills" => kills,
              "deaths" => deaths,
              "assists" => assists,
              "average_lifespan" => average_lifespan, 
              "win_rate" => win_rate,
              "kd_ratio" => kd,
              "games_played" => games_played,
              "elo" => elo,
              "kad_ratio" => kad,
              "games_won" => games_won,
              "games_lost" => (games_played.to_i - games_won.to_i),
              "kill_stats" => kill_stats
            }

            #check to make sure items array conatins all items
            item_types.each do|key, value|
              if !items.key?(value)
                items[value] = {
                  "item_icon": "https://www.bungie.net/common/destiny2_content/icons/ca4f74ff4b80283445b3831b1bb613bd.jpg",
                  "item_name": "NO DATA",
                  "item_tier": "NO DATA",
                  "item_type": "NO DATA"
                }
              end
              
            end
            @characters_stats << {"character_id" => character_id, "character_type" => character_type, "character_stats" => @stats, "character_items" => items, "recent_games" =>  nil }#get_recent_games(username, character_id)}
          end
          
          hydra.queue(get_trials_stats)

        end
      end
      hydra.queue(get_characters)
      hydra.run

      index = @characters_stats.index{|x| x["character_id"] == @last_character[0]}
      if index != 0
          @characters_stats[0], @characters_stats[index] = @characters_stats[index], @characters_stats[0]
      end

      @characters_stats
    end

    def old_stats(username)
      username.display_name.strip!
  
      user = username.display_name.include?(" ") ? username.display_name.gsub(/\s/,'%20') : username.display_name
  
      hydra = Typhoeus::Hydra.hydra
      
      elo = get_elo(username.api_membership_id)
          
      get_characters = Typhoeus::Request.new(
          # "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
          "https://www.bungie.net/Platform/Destiny2/1/Profile/4611686018439345596/?components=Characters,205",
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
                  12 => "emblem",
                  13 => "Shader",
                  14 => "Emote",
                  15 => "Horn",
                  16 => "Artifact",
                  17 => "emblem_background",
                  18 => "emblem"
              }
              
              items["emblem_background"] = "https://www.bungie.net#{x['backgroundPath']}" #emblem background
              items["emblem"] = "https://www.bungie.net/#{x['emblemPath']}"
  
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
                      # kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"] 
                      # deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"] 
                      # assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"] 
                      # games_played = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesEntered"]["basic"]["value"] 
                      # games_won = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesWon"]["basic"]["value"]
                      # avg_life_span = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageLifespan"]["basic"]["displayValue"]
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
                      # win_rate = (((games_won / games_played).round(2)) * 100).round
      
                      # kd = (kills / deaths).round(2)
                      # kad = ((kills + assists) / deaths).round(2)
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
                      "average_life_span" => avg_life_span,
                      "auto_rifle" => auto_rifle,
                      "fusion_rifle" => fusion_rifle, 
                      "hand_cannon" => hand_cannon,
                      "machine_gun" => machine_gun,
                      "pulse_rifle" => pulse_rifle,
                      "rocket_launcher" => rocket_launcher,
                      "scout_rifle" => scout_rifle,
                      "shotgun" => shotgun,
                      "sniper" => sniper,
                      "Sub Machine Gun" => sub_machine_gun,
                      "side_arm" => side_arm,
                      "sword" => sword,
                      "melee" => melee,
                      "grenades" => grenades,
                      "Super" => super_kills,
                      "ability" => ability_kills,
                      "longest_spree" => longest_spree,
                      "best_weapon_type" => weapon_best_type,
                      "Longest Life" => longest_life,
                      "Orbs Dropped" => orbs_dropped,
                      "revives_received" => res_received,
                      "revives_performed" => res_performed,
                      "precision_kills" => precision_kills,
                      "average_life_span" => average_lifespan,
                      "average_kill_distance" => avg_kill_distance,
                      "Average Death Distance" => avg_death_distance
                  }
  
                  @stats = {
                      "kills" => kills.round, 
                      "deaths" => deaths.round,
                      "Assists" => assists.round,
                      "kd_ratio" => kd,
                      "kad_ratio" => kad,
                      "Intellect" => stat_intellect,
                      "Discipline" => stat_dicipline,
                      "Strength" => stat_strength,
                      "elo" => elo,
                      "games_won" => games_won,
                      "games_lost" => (games_played - games_won),
                      "win_rate" => win_rate,
                      "Armor" => stat_armor,
                      "Agility" => stat_agility,
                      "Recovery" => stat_recovery,
                      "light_level" => light_level,
                      "grimoire" => grimoire,
                      "kill_stats" => kill_stats
                  }
  
                  @characters_stats << {"character_type" => character_type, "character_stats" => @stats, "Character Items" => items, "recent_games" => get_recent_games(username, character_id)}
                  
              end
                  
              hydra.queue(get_trials_stats)
              
          end
      end
  
      
      hydra.queue(get_characters)
      hydra.run
      @characters_stats
      
  end

  def get_characters2(user)
      character_races = {0 => "Titan", 1 => "Hunter", 2 => "Warlock"} 
      
      get_characters = Typhoeus.get(
          # "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
          "https://www.bungie.net/Platform/Destiny2/2/Profile/4611686018428389623/?components=Characters",
          headers: {"x-api-key" => ENV['API_TOKEN']}
      )

      character_data = JSON.parse(get_characters.body)

      characters = []

      character_data["Response"]["characters"]["data"].each do |x| 
         id =  x[1]["characterId"]
         subclass_val =  x[1]['classType']
         subclass = character_races[subclass_val.to_i]
         characters << [subclass, id]
      end

      characters  ###### STOP HERE FOR GETTING CHARACTERS

  end 
  helper_method :get_characters2

  
def test2(username)
    username.display_name.strip!
  
    user = username.display_name.include?(" ") ? username.display_name.gsub(/\s/,'%20') : username.display_name

    #returns characters for a given account  
    characters_stats = []   
    get_characters = Typhoeus::Request.get(
        # "https://www.bungie.net/d1/Platform/Destiny/#{username.api_membership_type}/Account/#{username.api_membership_id}/",
        "https://www.bungie.net/Platform/Destiny2/#{username.api_membership_type}/Profile/#{username.api_membership_id}/?components=Characters,205",
        method: :get,
        headers: {"x-api-key" => ENV['API_TOKEN']}
    )

    character_data = JSON.parse(get_characters.body)

    character_data["Response"]["characters"]["data"].each_with_index do |character, index| 
      if index == 0
        last_character = character[0]
      end 
      character_races = {0 => "Titan", 1 => "Hunter", 2 => "Warlock"} 
      character_id = character[0]
      # characters = []
      character_type = character[1]["classType"]
      subclass_name = character_races[character_type.to_i]
      light_level = character[1]["light"]
      emblem = "https://www.bungie.net#{character[1]['emblemPath']}"
      emblem_background = "https://www.bungie.net#{character[1]['emblemBackgroundPath']}"
      # @items = Hash.new      

      stats = {
        "light_level" => light_level,
        "grimoire" => 0,
        "background" => emblem_background,
        "emblem" => emblem,
        "subclass_icon" => "",
        "subclass_name" => subclass_name,
        "kills" => 0,
        "deaths" => 0,
        "average_lifespan" => 0, 
        "win_rate" => 0,
        "kd_ratio" => 0,
        "games_played" => 0
      }

        characters_stats << {"character_type" => character_type, "character_stats" => stats}
    end

    # characters_stats = Hash[*characters_stats]
    characters_stats     
  end
  helper_method :test2
    
    def get_stats(mode)
        begin
          case mode
          when "too"
            begin
              Rails.cache.fetch("user_trials_stats", expires_in: 2.minutes) do
                return current_user.get_trials_stats(current_user)
              end
            rescue NoMethodError => e
              return nil
            rescue StandardError => e
              return nil
            end
          end
         rescue NoMethodError
            redirect_to request.referer || root_url
            flash[:error] = "Error: Player Not Found!"
        rescue StandardError => e
            redirect_to root_url
            flash[:error] = "Error: #{e}"
        end
      end
    
      def get_map
        begin        
          hydra = Typhoeus::Hydra.hydra

            get_characters = Typhoeus::Request.new(
              "https://www.bungie.net/d1/Platform/Destiny/2/Account/4611686018428388122/",
              method: :get,
              headers: {"x-api-key" => ENV['API_TOKEN']}
          )
      
  
          get_characters.on_complete do |character_response|  
              character_data = JSON.parse(character_response.body)
              last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]
              get_last_activity = Typhoeus::Request.new(
                "https://www.bungie.net/d1/Platform/Destiny/Stats/ActivityHistory/2/4611686018428388122/#{last_character}/?mode=14&count=1&lc=en&definitions=true",
                method: :get,
                headers: {"x-api-key" => ENV['API_TOKEN']}
              ) 
              get_last_activity.on_complete do |activity_response|  
                activity_data = JSON.parse(activity_response.body)
                map_hash = activity_data["Response"]["data"]["activities"][0]["activityDetails"]["referenceId"]
                map_name = activity_data["Response"]["definitions"]["activities"]["#{map_hash}"]["activityName"]
                img = activity_data["Response"]["definitions"]["activities"]["#{map_hash}"]["pgcrImage"]
                icon = "https://www.bungie.net#{img}"
                
                @map_details = Hash.new
                @map_details["Image"] = icon
                @map_details["Name"] = map_name
              end
              hydra.queue(get_last_activity)

          end
          hydra.queue(get_characters)
          hydra.run

          @map_details

        rescue StandardError => e
          return nil
        end
      end
    
end
