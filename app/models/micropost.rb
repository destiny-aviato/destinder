class Micropost < ApplicationRecord
  
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  scope :game_type, -> (game_type) { where game_type: game_type }
  scope :platform, -> (platform) { where platform: platform }
  scope :raid_difficulty, -> (raid_difficulty) { where raid_difficulty: raid_difficulty }
  scope :looking_for, -> (raid_difficulty) { where looking_for: raid_difficulty }
  scope :mic_required, -> (mic_required) { where mic_required: mic_required }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 50 }
  validates :game_type, presence: true
  serialize :user_stats


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

  def self.get_raid_stats(user, raid, diff, character_id)
    case raid
    when "wrath"
      raid_hash = diff == "Normal" ? "260765522" : "1387993552"
    when "kings"
      raid_hash = diff == "Normal" ? "1733556769" : "3534581229"
    when "crota"
      raid_hash = diff == "Normal" ? "1836893116" : "1836893119"
    when "vog"
      raid_hash = diff == "Normal" ? "2659248071" : "2659248068"
    end

    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: {"x-api-key" => ENV['API_TOKEN']}
    )

    character_data = JSON.parse(get_characters.body)
    characters = character_data["Response"]["data"]["characters"]

    characters.each do |char|
      if char["characterBase"]["characterId"] == character_id
        @character = char
        break
      end
    end
    characters_stats = []
    

    character_id =  @character["characterBase"]["characterId"]
    character_type = @character["characterBase"]["classType"]
    light_level = @character["characterBase"]["powerLevel"]
    grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"
    completions = 0
    kills = 0
    deaths = 0
    kd = 0
    fastest_time_val = 0
    fastest_time = 'N/A'

    characters.each do |c|
      get_raid_stats = Typhoeus.get(
        "https://www.bungie.net/d1/Platform/Destiny/Stats/AggregateActivityStats/#{user.api_membership_type}/#{user.api_membership_id}/#{c['characterBase']['characterId']}/",        
        headers: {"x-api-key" => ENV['API_TOKEN']}
      )   
      
      stat_data = JSON.parse(get_raid_stats.body)

      vals = ""
      stat_data["Response"]["data"]["activities"].each do |x|
        if x["activityHash"] == raid_hash.to_i
          vals = x["values"]
          break
        end
      end

      if vals != ''
        completions += vals['activityCompletions']['basic']['displayValue'].to_i
        kills += vals['activityKills']['basic']['displayValue'].to_i
        deaths += vals['activityDeaths']['basic']['displayValue'].to_i
        kd = vals['activityKillsDeathsRatio']['basic']['displayValue'].to_f
        if fastest_time_val < vals['fastestCompletionSecondsForActivity']['basic']['value'] 
          fastest_time_val = vals['fastestCompletionSecondsForActivity']['basic']['value']
          fastest_time = vals['fastestCompletionSecondsForActivity']['basic']['displayValue']
        end
      else
        next
        completions = 'N/A'
        kills = 'N/A'
        deaths = 'N/A'
        kd = 'N/A'
        fastest_time = 'N/A'
      end
    end 


    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: {"x-api-key" => ENV['API_TOKEN']}
    )


    get_items.on_complete do |item_response|                     
        item_data = JSON.parse(item_response.body)
        @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
        @subclass_name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
    end
    
    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run
   
  
    stats = {
      "Completions" => completions,
      "Kills" => kills,
      "Deaths" => deaths,
      "K/D" => kd,
      "Fastest" => fastest_time,
      "Light Level" => light_level,
      "Grimoire" => grimoire,
      "Background" => background,
      "Emblem" => emblem,
      "Subclass Icon" => @subclass_icon,
      "Subclass Name" => @subclass_name
    }
    characters_stats << {"Character Type" => character_type, "Character Stats" => stats}
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_nightfall_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: {"x-api-key" => ENV['API_TOKEN']}
    )

    character_data = JSON.parse(get_characters.body)

    character_data["Response"]["data"]["characters"].each do |char|
      if char["characterBase"]["characterId"] == character_id
        @character = char
        break
      end
    end

    characters_stats = []
    

    character_id =  @character["characterBase"]["characterId"]
    character_type = @character["characterBase"]["classType"]
    light_level = @character["characterBase"]["powerLevel"]
    grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: {"x-api-key" => ENV['API_TOKEN']}
      )


    get_items.on_complete do |item_response|                     
        item_data = JSON.parse(item_response.body)
        @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
        @subclass_name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
    end
    
    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run
   
  
    stats = {
      "Completions" => "-",
      "Kills" => "-",
      "Deaths" => "-",
      "K/D" => "-",
      "Fastest" => "-",
      "Light Level" => light_level,
      "Grimoire" => grimoire,
      "Background" => background,
      "Emblem" => emblem,
      "Subclass Icon" => @subclass_icon,
      "Subclass Name" => @subclass_name
    }
    characters_stats << {"Character Type" => character_type, "Character Stats" => stats}
    characters_stats = Hash[*characters_stats]
    characters_stats
  end


  def self.get_trials_stats(user, character_id)
    cache_key = "postsStats|#{user.id}|#{user.updated_at}"
    Rails.cache.fetch("#{cache_key}/trials_stats", expires_in: 2.minutes) do
      elo = get_elo(user.api_membership_id)
      get_characters = Typhoeus.get(
          "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
          headers: {"x-api-key" => ENV['API_TOKEN']}
      )

      character_data = JSON.parse(get_characters.body)

      character_data["Response"]["data"]["characters"].each do |char|
        if char["characterBase"]["characterId"] == character_id
          @character = char
          break
        end
      end

      # @character = character_data["Response"]["data"]["characters"][0]
      characters_stats = []

        character_id =  @character["characterBase"]["characterId"]
        background = "https://www.bungie.net/#{@character['backgroundPath']}"
        emblem = "https://www.bungie.net/#{@character['emblemPath']}"
        character_type = @character["characterBase"]["classType"]
        light_level = @character["characterBase"]["powerLevel"]
        grimoire = @character["characterBase"]["grimoireScore"]
        begin 

          get_items = Typhoeus::Request.new(
            "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
            method: :get,
            headers: {"x-api-key" => ENV['API_TOKEN']}
            )
    

          get_items.on_complete do |item_response|                     
              item_data = JSON.parse(item_response.body)
              @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
              @subclass_name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
          end
          hydra = Typhoeus::Hydra.hydra
          hydra.queue(get_items)
          hydra.run
         
          get_trials_stats = Typhoeus.get(
                      "https://www.bungie.net/d1/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{character_id}/?modes=14",
                      headers: {"x-api-key" => ENV['API_TOKEN']}
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
              "ELO" => elo,
              "Win Rate" => win_rate,
              "Light Level" => light_level,
              "Grimoire" => grimoire,
              "Background" => background,
              "Emblem" => emblem,
              "Subclass Icon" => @subclass_icon,
              "Subclass Name" => @subclass_name
          }
        rescue StandardError => e 
          stats = {
            "K/D Ratio" => "-",
            "KA/D Ratio" => "-",
            "ELO" => "-",
            "Win Rate" => "-",
            "Light Level" => light_level,
            "Grimoire" => grimoire,
            "Background" => background,
            "Emblem" => emblem,
            "Subclass Icon" => @subclass_icon,
            "Subclass Name" => @subclass_name
        }
        end


        characters_stats << {"Character Type" => character_type, "Character Stats" => stats}
        characters_stats = Hash[*characters_stats]
      
        characters_stats
      end
  end
end
