class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  scope :game_type, ->(game_type) { where game_type: game_type }
  scope :platform, ->(platform) { where platform: platform }
  scope :raid_difficulty, ->(raid_difficulty) { where raid_difficulty: raid_difficulty }
  scope :looking_for, ->(raid_difficulty) { where looking_for: raid_difficulty }
  scope :mic_required, ->(mic_required) { where mic_required: mic_required }
  scope :destiny_version, ->(destiny_version) { where destiny_version: destiny_version }
  scope :elo_min, ->(elo_min) { where('elo >= ?', elo_min) }
  scope :elo_max, ->(elo_max) { where('elo <= ?', elo_max) }
  scope :kd_min, ->(kd_min) { where('kd >= ?', kd_min) }
  scope :kd_max, ->(kd_max) { where('kd <= ?', kd_max) }
  validates :user_id, presence: true
  validates :content, length: { maximum: 50 }
  validates :game_type, presence: true
  serialize :user_stats
  serialize :fireteam_stats

  def self.get_elo(membership_id)
    elo = 1200
    rank = 0

    begin
      response = Typhoeus.get(
        "https://api.guardian.gg/elo/#{membership_id}"
      )

      data = JSON.parse(response.body)

      data.each do |x|
        next unless x['mode'] == 14
        elo = x['elo']
        rank = x['rank']
        break
      end
    rescue StandardError => e
      puts e
    end

    { 'elo' => elo.round, 'rank' => rank.round }
  end

  def self.get_elo_d2(membership_type, membership_id)
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

  def self.get_raid_stats(user, raid, diff, character_id)
    case raid
    when 'wrath'
      raid_hash = diff == 'Normal' ? '260765522' : '1387993552'
    when 'kings'
      raid_hash = diff == 'Normal' ? '1733556769' : '3534581229'
    when 'crota'
      raid_hash = diff == 'Normal' ? '1836893116' : '1836893119'
    when 'vog'
      raid_hash = diff == 'Normal' ? '2659248071' : '2659248068'
    end

    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)
    characters = character_data['Response']['data']['characters']

    characters.each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end
    characters_stats = []

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
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
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_raid_stats.body)

      vals = ''
      stat_data['Response']['data']['activities'].each do |x|
        if x['activityHash'] == raid_hash.to_i
          vals = x['values']
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
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_items.on_complete do |item_response|
      item_data = JSON.parse(item_response.body)
      @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
      @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run

    stats = {
      'completions' => completions,
      'kills' => kills,
      'deaths' => deaths,
      'kd_ratio' => kd,
      'fastest' => fastest_time,
      'light_level' => light_level,
      'grimoire' => grimoire,
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => @subclass_icon,
      'subclass_name' => @subclass_name
    }
    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_storyold_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)
    characters = character_data['Response']['data']['characters']

    characters.each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    characters.each do |c|
      begin
        get_story_stats = Typhoeus.get(
          "https://www.bungie.net/d1/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{c['characterBase']['characterId']}/?modes=0&definitions=true",
          headers: { 'x-api-key' => ENV['API_TOKEN'] }
        )

        stat_data = JSON.parse(get_story_stats.body)

        stats = stat_data['Response']['story']['allTime']

        activities_cleared = stats['activitiesCleared']['basic']['displayValue']
        activities_entered = stats['activitiesEntered']['basic']['displayValue']
        completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
        kills = stats['kills']['basic']['displayValue']
        deaths = stats['deaths']['basic']['displayValue']
        average_lifespan = stats['averageLifespan']['basic']['displayValue']
        revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
        revives_received = stats['resurrectionsReceived']['basic']['displayValue']
        suicides = stats['suicides']['basic']['displayValue']
        best_weapon = stats['weaponBestType']['basic']['displayValue']
        fastest_time = stats['fastestCompletion']['basic']['displayValue']
        kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      rescue StandardError => e
        activities_cleared = '0'
        activities_entered = '0'
        completion_rate = '0'
        kills = '0'
        deaths = '0'
        average_lifespan = 'N/A'
        revives_given = '0'
        revives_received = '0'
        suicides = '0'
        best_weapon = '0'
        fastest_time = '0'
        kd_ratio = '0'
      end

      get_items = Typhoeus::Request.new(
        "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
        method: :get,
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      get_items.on_complete do |item_response|
        item_data = JSON.parse(item_response.body)
        @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
        @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
      end

      hydra = Typhoeus::Hydra.hydra
      hydra.queue(get_items)
      hydra.run

      stats = {
        'light_level' => light_level,
        'grimoire' => grimoire,
        'background' => background,
        'emblem' => emblem,
        'subclass_icon' => @subclass_icon,
        'subclass_name' => @subclass_name,
        'activities_cleared' => activities_cleared,
        'activities_entered' => activities_entered,
        'activity_completion_rate' => completion_rate,
        'kills' => kills,
        'deaths' => deaths,
        'average_lifespan' => average_lifespan,
        'revives_given' => revives_given,
        'revives_received' => revives_received,
        'suicides' => suicides,
        'best_weapon' => best_weapon,
        'fastest_time' => fastest_time,
        'kd_ratio' => kd_ratio
      }

      characters_stats = []
      characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
      characters_stats = Hash[*characters_stats]
      characters_stats
    end
  end

  def self.get_nightfall_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    character_data['Response']['data']['characters'].each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end

    characters_stats = []

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_items.on_complete do |item_response|
      item_data = JSON.parse(item_response.body)
      @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
      @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run

    stats = {
      'completions' => '-',
      'kills' => '-',
      'deaths' => '-',
      'kd_ratio' => '-',
      'fastest' => '-',
      'light_level' => light_level,
      'grimoire' => grimoire,
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => @subclass_icon,
      'subclass_name' => @subclass_name
    }
    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_story_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    character_data['Response']['data']['characters'].each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end

    characters_stats = []

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/d1/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{@character['characterBase']['characterId']}/?modes=0&definitions=true",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['story']['allTime']

      activities_cleared = stats['activitiesCleared']['basic']['displayValue']
      activities_entered = stats['activitiesEntered']['basic']['displayValue']
      completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
      revives_received = stats['resurrectionsReceived']['basic']['displayValue']
      suicides = stats['suicides']['basic']['displayValue']
      best_weapon = stats['weaponBestType']['basic']['displayValue']
      fastest_time = stats['fastestCompletion']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
    rescue StandardError => e
      activities_cleared = '0'
      activities_entered = '0'
      completion_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = 'N/A'
      revives_given = '0'
      revives_received = '0'
      suicides = '0'
      best_weapon = '0'
      fastest_time = '0'
      kd_ratio = '0'
    end

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_items.on_complete do |item_response|
      item_data = JSON.parse(item_response.body)
      @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
      @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run

    stats = {
      'light_level' => light_level,
      'grimoire' => grimoire,
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => @subclass_icon,
      'subclass_name' => @subclass_name,
      'activities_cleared' => activities_cleared,
      'activities_entered' => activities_entered,
      'activity_completion_rate' => completion_rate,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'revives_given' => revives_given,
      'revives_received' => revives_received,
      'suicides' => suicides,
      'best_weapon' => best_weapon,
      'fastest_time' => fastest_time,
      'kd_ratio' => kd_ratio
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_strikes_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    character_data['Response']['data']['characters'].each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end

    characters_stats = []

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/d1/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{@character['characterBase']['characterId']}/?modes=0&definitions=true",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['allStrikes']['allTime']

      activities_cleared = stats['activitiesCleared']['basic']['displayValue']
      activities_entered = stats['activitiesEntered']['basic']['displayValue']
      completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
      revives_received = stats['resurrectionsReceived']['basic']['displayValue']
      suicides = stats['suicides']['basic']['displayValue']
      best_weapon = stats['weaponBestType']['basic']['displayValue']
      fastest_time = stats['fastestCompletion']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
    rescue StandardError => e
      activities_cleared = '0'
      activities_entered = '0'
      completion_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = 'N/A'
      revives_given = '0'
      revives_received = '0'
      suicides = '0'
      best_weapon = '0'
      fastest_time = '0'
      kd_ratio = '0'
    end

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_items.on_complete do |item_response|
      item_data = JSON.parse(item_response.body)
      @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
      @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run

    stats = {
      'light_level' => light_level,
      'grimoire' => grimoire,
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => @subclass_icon,
      'subclass_name' => @subclass_name,
      'activities_cleared' => activities_cleared,
      'activities_entered' => activities_entered,
      'activity_completion_rate' => completion_rate,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'revives_given' => revives_given,
      'revives_received' => revives_received,
      'suicides' => suicides,
      'best_weapon' => best_weapon,
      'fastest_time' => fastest_time,
      'kd_ratio' => kd_ratio
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_pvp_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    character_data['Response']['data']['characters'].each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end

    characters_stats = []

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/d1/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{@character['characterBase']['characterId']}/?modes=0&definitions=true",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['allPvP']['allTime']
      win_rate = stats['winLossRatio']['basic']['displayValue']
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      games_played = stats['activitiesEntered']['basic']['displayValue']
    rescue StandardError => e
      win_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = '0'
      kd_ratio = '0'
      games_played = '0'
    end

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_items.on_complete do |item_response|
      item_data = JSON.parse(item_response.body)
      @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
      @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run

    stats = {
      'light_level' => light_level,
      'grimoire' => grimoire,
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => @subclass_icon,
      'subclass_name' => @subclass_name,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'win_rate' => win_rate,
      'kd_ratio' => kd_ratio,
      'games_played' => games_played
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_other_stats(user, character_id)
    get_characters = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    character_data['Response']['data']['characters'].each do |char|
      if char['characterBase']['characterId'] == character_id
        @character = char
        break
      end
    end

    characters_stats = []

    character_id = @character['characterBase']['characterId']
    character_type = @character['characterBase']['classType']
    light_level = @character['characterBase']['powerLevel']
    grimoire = @character['characterBase']['grimoireScore']
    background = "https://www.bungie.net/#{@character['backgroundPath']}"
    emblem = "https://www.bungie.net/#{@character['emblemPath']}"

    get_items = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_items.on_complete do |item_response|
      item_data = JSON.parse(item_response.body)
      @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
      @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
    end

    hydra = Typhoeus::Hydra.hydra
    hydra.queue(get_items)
    hydra.run

    stats = {
      'completions' => '-',
      'kills' => '-',
      'deaths' => '-',
      'kd_ratio' => '-',
      'fastest' => '-',
      'light_level' => light_level,
      'grimoire' => grimoire,
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => @subclass_icon,
      'subclass_name' => @subclass_name
    }
    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_trials_stats(user, character_id)
    cache_key = "postsStats|#{user.id}|#{user.updated_at}"
    Rails.cache.fetch("#{cache_key}/trials_stats", expires_in: 2.minutes) do
      elo = get_elo(user.api_membership_id)
      get_characters = Typhoeus.get(
        # "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/"
        "https://www.bungie.net/d1/Platform/Destiny/#{user.api_membership_type}/Account/#{user.api_membership_id}/",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      character_data = JSON.parse(get_characters.body)

      character_data['Response']['data']['characters'].each do |char|
        if char['characterBase']['characterId'] == character_id
          @character = char
          break
        end
      end

      # @character = character_data["Response"]["data"]["characters"][0]
      characters_stats = []

      character_id = @character['characterBase']['characterId']
      background = "https://www.bungie.net/#{@character['backgroundPath']}"
      emblem = "https://www.bungie.net/#{@character['emblemPath']}"
      character_type = @character['characterBase']['classType']
      light_level = @character['characterBase']['powerLevel']
      grimoire = @character['characterBase']['grimoireScore']
      begin
        get_items = Typhoeus::Request.new(
          # "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/"
          "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
          method: :get,
          headers: { 'x-api-key' => ENV['API_TOKEN'] }
        )

        get_items.on_complete do |item_response|
          item_data = JSON.parse(item_response.body)
          @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
          @subclass_name = item_data['Response']['data']['inventoryItem']['itemName']
        end
        hydra = Typhoeus::Hydra.hydra
        hydra.queue(get_items)
        hydra.run

        get_trials_stats = Typhoeus.get(
          "https://www.bungie.net/d1/Platform/Destiny/Stats/#{user.api_membership_type}/#{user.api_membership_id}/#{character_id}/?modes=14",
          headers: { 'x-api-key' => ENV['API_TOKEN'] }
        )

        stat_data = JSON.parse(get_trials_stats.body)

        kills = stat_data['Response']['trialsOfOsiris']['allTime']['kills']['basic']['value']
        deaths = stat_data['Response']['trialsOfOsiris']['allTime']['deaths']['basic']['value']
        assists = stat_data['Response']['trialsOfOsiris']['allTime']['assists']['basic']['value']
        games_played = stat_data['Response']['trialsOfOsiris']['allTime']['activitiesEntered']['basic']['value']
        games_won = stat_data['Response']['trialsOfOsiris']['allTime']['activitiesWon']['basic']['value']
        avg_life_span = stat_data['Response']['trialsOfOsiris']['allTime']['averageLifespan']['basic']['displayValue']

        win_rate = ((games_won / games_played).round(2) * 100).round

        kd = (kills / deaths).round(2)
        kad = ((kills + assists) / deaths).round(2)

        stats = {
          'kd_ratio' => kd,
          'kad_ratio' => kad,
          'elo' => elo,
          'win_rate' => win_rate,
          'light_level' => light_level,
          'grimoire' => grimoire,
          'background' => background,
          'emblem' => emblem,
          'subclass_icon' => @subclass_icon,
          'subclass_name' => @subclass_name
        }
      rescue StandardError => e
        stats = {
          'kd_ratio' => '-',
          'kad_ratio' => '-',
          'elo' => '-',
          'win_rate' => '-',
          'light_level' => light_level,
          'grimoire' => grimoire,
          'background' => background,
          'emblem' => emblem,
          'subclass_icon' => @subclass_icon,
          'subclass_name' => @subclass_name
        }
      end

      characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
      characters_stats = Hash[*characters_stats]

      characters_stats
    end
  end

  def self.get_other_stats_d2(user, character_id)
    begin
       subclasses = {
         '3225959819' => 'Nightstalker',
         '3635991036' => 'Gunslinger',
         '1334959255' => 'Arcstrider',
         '3887892656' => 'Voidwalker',
         '1751782730' => 'Stormcaller',
         '3481861797' => 'Dawnblade',
         '2958378809' => 'Striker',
         '3105935002' => 'Sunbreaker',
         '3382391785' => 'Sentinel',
         '2863201134' => 'Lost Light',
         '2934029575' => 'Lost Light',
         '1112909340' => 'Lost Light'
       }
       character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
       get_characters = Typhoeus::Request.get(
         # "https://www.bungie.net/d1/Platform/Destiny/#{username.api_membership_type}/Account/#{username.api_membership_id}/",
         "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
         method: :get,
         headers: { 'x-api-key' => ENV['API_TOKEN'] }
       )

       character_data = JSON.parse(get_characters.body)

       # character_data["Response"]["data"]["characters"].each do |char|
       character_data['Response']['characters']['data'].each do |char|
         if char[0] == character_id
           @character = char
           break
         end
       end

       character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
         if item['bucketHash'] == '3284755031'.to_i
           @subclass_name = subclasses[item['itemHash'].to_s]
           break
         else
           puts item['bucketHash']
           next
         end
       end

       characters_stats = []

       character_id = @character[0]
       character_type = @character[1]['classType']
       light_level = @character[1]['light']
       # grimoire = @character["characterBase"]["grimoireScore"]
       background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
       emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"
       # get_items = Typhoeus::Request.new(
       #   # "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
       #   "https://www.bungie.net/Platform/Destiny2/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
       #   method: :get,
       #   headers: {"x-api-key" => ENV['API_TOKEN']}
       #   )

       # get_items.on_complete do |item_response|
       #     item_data = JSON.parse(item_response.body)
       #     @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
       #     @subclass_name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
       # end

       # hydra = Typhoeus::Hydra.hydra
       # hydra.queue(get_items)
       # hydra.run

       stats = {
         'completions' => '-',
         'kills' => '-',
         'deaths' => '-',
         'kd_ratio' => '-',
         'fastest' => '-',
         'light_level' => light_level,
         'grimoire' => '-',
         'background' => background,
         'emblem' => emblem,
         'subclass_icon' => '',
         'subclass_name' => @subclass_name
       }
       characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
     rescue StandardError => e
       characters_stats = []
       stats = {
         'completions' => '-',
         'kills' => '-',
         'deaths' => '-',
         'kd_ratio' => '-',
         'fastest' => '-',
         'light_level' => 'LVL',
         'grimoire' => 'GRIM',
         'background' => 'https://www.bungie.net/common/destiny_content/icons/4b7ec936d5acb61f37077d0783952573.jpg',
         'emblem' => 'https://s3.amazonaws.com/destinder/temp.png',
         'subclass_icon' => @subclass_icon,
         'subclass_name' => @subclass_name
       }
       characters_stats << { 'player_name' => user.display_name, 'character_type' => character_races[character_type.to_i], 'character_stats' => stats }
     end

    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_story_stats_d2(user, character_id)
    subclasses = {
      '3225959819' => 'Nightstalker',
      '3635991036' => 'Gunslinger',
      '1334959255' => 'Arcstrider',
      '3887892656' => 'Voidwalker',
      '1751782730' => 'Stormcaller',
      '3481861797' => 'Dawnblade',
      '2958378809' => 'Striker',
      '3105935002' => 'Sunbreaker',
      '3382391785' => 'Sentinel',
      '2863201134' => 'Lost Light',
      '2934029575' => 'Lost Light',
      '1112909340' => 'Lost Light'
    }
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
    get_characters = Typhoeus::Request.get(
      # "https://www.bungie.net/d1/Platform/Destiny/#{username.api_membership_type}/Account/#{username.api_membership_id}/",
      "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    # character_data["Response"]["data"]["characters"].each do |char|
    character_data['Response']['characters']['data'].each do |char|
      if char[0] == character_id
        @character = char
        break
      end
    end

    character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
      if item['bucketHash'] == '3284755031'.to_i
        @subclass_name = subclasses[item['itemHash'].to_s]
        break
      else
        puts item['bucketHash']
        next
      end
    end

    characters_stats = []

    character_id = @character[0]
    character_type = @character[1]['classType']
    light_level = @character[1]['light']
    # grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
    emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/Character/#{character_id}/Stats/",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['story']['allTime']

      activities_cleared = stats['activitiesCleared']['basic']['displayValue']
      activities_entered = stats['activitiesEntered']['basic']['displayValue']
      completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
      revives_received = stats['resurrectionsReceived']['basic']['displayValue']
      suicides = stats['suicides']['basic']['displayValue']
      best_weapon = stats['weaponBestType']['basic']['displayValue']
      fastest_time = stats['fastestCompletionMs']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      highest_level = stats['highestCharacterLevel']['basic']['displayValue']
      highest_light = stats['highestLightLevel']['basic']['displayValue']
    rescue StandardError => e
      activities_cleared = '0'
      activities_entered = '0'
      completion_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = 'N/A'
      revives_given = '0'
      revives_received = '0'
      suicides = '0'
      best_weapon = '0'
      fastest_time = '0'
      kd_ratio = '0'
      highest_level = '0'
      highest_light = '0'
    end

    # get_items = Typhoeus::Request.new(
    #   "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
    #   method: :get,
    #   headers: {"x-api-key" => ENV['API_TOKEN']}
    #   )

    # get_items.on_complete do |item_response|
    #     item_data = JSON.parse(item_response.body)
    #     @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
    #     @subclass_name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
    # end

    stats = {
      'light_level' => light_level,
      'grimoire' => '0',
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => '',
      'subclass_name' => @subclass_name,
      'activities_cleared' => activities_cleared,
      'activities_entered' => activities_entered,
      'activity_completion_rate' => completion_rate,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'revives_given' => revives_given,
      'revives_received' => revives_received,
      'suicides' => suicides,
      'best_weapon' => best_weapon,
      'fastest_time' => fastest_time,
      'kd_ratio' => kd_ratio,
      'highest_level' => highest_level,
      'highest_light' => highest_light
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_strikes_stats_d2(user, character_id)
    subclasses = {
      '3225959819' => 'Nightstalker',
      '3635991036' => 'Gunslinger',
      '1334959255' => 'Arcstrider',
      '3887892656' => 'Voidwalker',
      '1751782730' => 'Stormcaller',
      '3481861797' => 'Dawnblade',
      '2958378809' => 'Striker',
      '3105935002' => 'Sunbreaker',
      '3382391785' => 'Sentinel',
      '2863201134' => 'Lost Light',
      '2934029575' => 'Lost Light',
      '1112909340' => 'Lost Light'
    }
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
    get_characters = Typhoeus::Request.get(
      "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    # character_data["Response"]["data"]["characters"].each do |char|
    character_data['Response']['characters']['data'].each do |char|
      if char[0] == character_id
        @character = char
        break
      end
    end

    character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
      if item['bucketHash'] == '3284755031'.to_i
        @subclass_name = subclasses[item['itemHash'].to_s]
        break
      else
        puts item['bucketHash']
        next
      end
    end

    characters_stats = []

    character_id = @character[0]
    character_type = @character[1]['classType']
    light_level = @character[1]['light']
    # grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
    emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/Character/#{character_id}/Stats/",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['allStrikes']['allTime']

      activities_cleared = stats['activitiesCleared']['basic']['displayValue']
      activities_entered = stats['activitiesEntered']['basic']['displayValue']
      completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
      revives_received = stats['resurrectionsReceived']['basic']['displayValue']
      suicides = stats['suicides']['basic']['displayValue']
      best_weapon = stats['weaponBestType']['basic']['displayValue']
      fastest_time = stats['fastestCompletionMs']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      highest_level = stats['highestCharacterLevel']['basic']['displayValue']
      highest_light = stats['highestLightLevel']['basic']['displayValue']
    rescue StandardError => e
      activities_cleared = '0'
      activities_entered = '0'
      completion_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = 'N/A'
      revives_given = '0'
      revives_received = '0'
      suicides = '0'
      best_weapon = '0'
      fastest_time = '0'
      kd_ratio = '0'
      highest_level = '0'
      highest_light = '0'
    end

    stats = {
      'light_level' => light_level,
      'grimoire' => '0',
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => '',
      'subclass_name' => @subclass_name,
      'activities_cleared' => activities_cleared,
      'activities_entered' => activities_entered,
      'activity_completion_rate' => completion_rate,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'revives_given' => revives_given,
      'revives_received' => revives_received,
      'suicides' => suicides,
      'best_weapon' => best_weapon,
      'fastest_time' => fastest_time,
      'kd_ratio' => kd_ratio,
      'highest_level' => highest_level,
      'highest_light' => highest_light
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_pvp_stats_d2(user, character_id)
    subclasses = {
      '3225959819' => 'Nightstalker',
      '3635991036' => 'Gunslinger',
      '1334959255' => 'Arcstrider',
      '3887892656' => 'Voidwalker',
      '1751782730' => 'Stormcaller',
      '3481861797' => 'Dawnblade',
      '2958378809' => 'Striker',
      '3105935002' => 'Sunbreaker',
      '3382391785' => 'Sentinel',
      '2863201134' => 'Lost Light',
      '2934029575' => 'Lost Light',
      '1112909340' => 'Lost Light'
    }
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
    get_characters = Typhoeus::Request.get(
      "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    # character_data["Response"]["data"]["characters"].each do |char|
    character_data['Response']['characters']['data'].each do |char|
      if char[0] == character_id
        @character = char
        break
      end
    end

    character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
      if item['bucketHash'] == '3284755031'.to_i
        @subclass_name = subclasses[item['itemHash'].to_s]
        break
      else
        puts item['bucketHash']
        next
      end
    end

    characters_stats = []

    character_id = @character[0]
    character_type = @character[1]['classType']
    light_level = @character[1]['light']
    # grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
    emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"
    # subclass_name = character_races[character_type.to_i]

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/Character/#{character_id}/Stats/",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['allPvP']['allTime']

      win_rate = stats['winLossRatio']['basic']['displayValue']
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      games_played = stats['activitiesEntered']['basic']['displayValue']
    rescue StandardError => e
      win_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = '0'
      kd_ratio = '0'
      games_played = '0'
    end

    stats = {
      'light_level' => light_level,
      'grimoire' => '0',
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => '',
      'subclass_name' => @subclass_name,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'win_rate' => win_rate,
      'kd_ratio' => kd_ratio,
      'games_played' => games_played
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_nightfall_stats_d2(user, character_id)
    subclasses = {
      '3225959819' => 'Nightstalker',
      '3635991036' => 'Gunslinger',
      '1334959255' => 'Arcstrider',
      '3887892656' => 'Voidwalker',
      '1751782730' => 'Stormcaller',
      '3481861797' => 'Dawnblade',
      '2958378809' => 'Striker',
      '3105935002' => 'Sunbreaker',
      '3382391785' => 'Sentinel',
      '2863201134' => 'Lost Light',
      '2934029575' => 'Lost Light',
      '1112909340' => 'Lost Light'
    }
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
    get_characters = Typhoeus::Request.get(
      "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    # character_data["Response"]["data"]["characters"].each do |char|
    character_data['Response']['characters']['data'].each do |char|
      if char[0] == character_id
        @character = char
        break
      end
    end

    character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
      if item['bucketHash'] == '3284755031'.to_i
        @subclass_name = subclasses[item['itemHash'].to_s]
        break
      else
        puts item['bucketHash']
        next
      end
    end

    characters_stats = []

    character_id = @character[0]
    character_type = @character[1]['classType']
    light_level = @character[1]['light']
    # grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
    emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/Character/#{character_id}/Stats/?modes=16",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['nightfall']['allTime']

      activities_cleared = stats['activitiesCleared']['basic']['displayValue']
      activities_entered = stats['activitiesEntered']['basic']['displayValue']
      completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
      revives_received = stats['resurrectionsReceived']['basic']['displayValue']
      suicides = stats['suicides']['basic']['displayValue']
      best_weapon = stats['weaponBestType']['basic']['displayValue']
      fastest_time = stats['fastestCompletionMs']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      highest_level = stats['highestCharacterLevel']['basic']['displayValue']
      highest_light = stats['highestLightLevel']['basic']['displayValue']
    rescue StandardError => e
      activities_cleared = '0'
      activities_entered = '0'
      completion_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = 'N/A'
      revives_given = '0'
      revives_received = '0'
      suicides = '0'
      best_weapon = '0'
      fastest_time = '0'
      kd_ratio = '0'
      highest_level = '0'
      highest_light = '0'
    end

    stats = {
      'light_level' => light_level,
      'grimoire' => '0',
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => '',
      'subclass_name' => @subclass_name,
      'activities_cleared' => activities_cleared,
      'activities_entered' => activities_entered,
      'activity_completion_rate' => completion_rate,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'revives_given' => revives_given,
      'revives_received' => revives_received,
      'suicides' => suicides,
      'best_weapon' => best_weapon,
      'fastest_time' => fastest_time,
      'kd_ratio' => kd_ratio,
      'highest_level' => highest_level,
      'highest_light' => highest_light
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_trials_stats_d2(user, character_id)
    subclasses = {
      '3225959819' => 'Nightstalker',
      '3635991036' => 'Gunslinger',
      '1334959255' => 'Arcstrider',
      '3887892656' => 'Voidwalker',
      '1751782730' => 'Stormcaller',
      '3481861797' => 'Dawnblade',
      '2958378809' => 'Striker',
      '3105935002' => 'Sunbreaker',
      '3382391785' => 'Sentinel',
      '2863201134' => 'Lost Light',
      '2934029575' => 'Lost Light',
      '1112909340' => 'Lost Light'
    }
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
    get_characters = Typhoeus::Request.get(
      "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    # character_data["Response"]["data"]["characters"].each do |char|
    character_data['Response']['characters']['data'].each do |char|
      if char[0] == character_id
        @character = char
        break
      end
    end

    character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
      if item['bucketHash'] == '3284755031'.to_i
        @subclass_name = subclasses[item['itemHash'].to_s]
        break
      else
        puts item['bucketHash']
        next
      end
    end

    characters_stats = []

    character_id = @character[0]
    character_type = @character[1]['classType']
    light_level = @character[1]['light']
    # grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
    emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"
    # subclass_name = character_races[character_type.to_i]

    begin
      get_story_stats = Typhoeus.get(
        # "https://www.bungie.net/Platform/Destiny2/1/Account/4611686018439345596/Character/2305843009260359587/Stats/?modes=39",
        "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/Character/#{character_id}/Stats/?modes=39",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['trialsofthenine']['allTime']
      elo = get_elo_d2(user.api_membership_type, user.api_membership_id)

      # win_rate = stats["winLossRatio"]["basic"]["displayValue"]
      kills = stats['kills']['basic']['displayValue']
      assists = stats['assists']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      games_played = stats['activitiesEntered']['basic']['displayValue']
      games_won = stats['activitiesWon']['basic']['value']
      kad = stats['killsDeathsAssists']['basic']['displayValue']
      kd = stats['killsDeathsRatio']['basic']['displayValue']
      win_rate = stats['winLossRatio']['basic']['displayValue']

      # win_rate = (((games_won / games_played.to_f).round(2)) * 100).round

      # kd = (kills.to_f / deaths.to_f).round(2)
      # kad = ((kills.to_f + assists.to_f) / deaths.to_f).round(2)
    rescue StandardError => e
      win_rate = '-'
      kills = '-'
      deaths = '-'
      average_lifespan = '-'
      kd = '-'
      kad = '-'
      games_played = '0'
    end

    stats = {
      'light_level' => light_level,
      'grimoire' => '0',
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => '',
      'subclass_name' => @subclass_name,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'win_rate' => win_rate,
      'kd_ratio' => kd,
      'games_played' => games_played,
      'elo' => elo,
      'kad_ratio' => kad
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
  end

  def self.get_raid_stats_d2(user, character_id)
    subclasses = {
      '3225959819' => 'Nightstalker',
      '3635991036' => 'Gunslinger',
      '1334959255' => 'Arcstrider',
      '3887892656' => 'Voidwalker',
      '1751782730' => 'Stormcaller',
      '3481861797' => 'Dawnblade',
      '2958378809' => 'Striker',
      '3105935002' => 'Sunbreaker',
      '3382391785' => 'Sentinel',
      '2863201134' => 'Lost Light',
      '2934029575' => 'Lost Light',
      '1112909340' => 'Lost Light'
    }
    character_races = { 0 => 'Titan', 1 => 'Hunter', 2 => 'Warlock' }
    get_characters = Typhoeus::Request.get(
      # "https://www.bungie.net/d1/Platform/Destiny/#{username.api_membership_type}/Account/#{username.api_membership_id}/",
      "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    character_data = JSON.parse(get_characters.body)

    # character_data["Response"]["data"]["characters"].each do |char|
    character_data['Response']['characters']['data'].each do |char|
      if char[0] == character_id
        @character = char
        break
      end
    end

    character_data['Response']['characterEquipment']['data'][character_id]['items'].each do |item|
      if item['bucketHash'] == '3284755031'.to_i
        @subclass_name = subclasses[item['itemHash'].to_s]
        break
      else
        puts item['bucketHash']
        next
      end
    end

    characters_stats = []

    character_id = @character[0]
    character_type = @character[1]['classType']
    light_level = @character[1]['light']
    # grimoire = @character["characterBase"]["grimoireScore"]
    background = "https://www.bungie.net#{@character[1]['emblemBackgroundPath']}"
    emblem = "https://www.bungie.net#{@character[1]['emblemPath']}"

    begin
      get_story_stats = Typhoeus.get(
        "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Account/#{user.api_membership_id}/Character/#{character_id}/Stats/?modes=4",
        # "https://www.bungie.net/Platform/Destiny2/2/Account/4611686018428388122/Character/2305843009260593955/Stats/?modes=4",
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      stat_data = JSON.parse(get_story_stats.body)

      stats = stat_data['Response']['raid']['allTime']

      activities_cleared = stats['activitiesCleared']['basic']['displayValue']
      activities_entered = stats['activitiesEntered']['basic']['displayValue']
      completion_rate = (activities_cleared.to_f / activities_entered.to_f).round(2) * 100
      kills = stats['kills']['basic']['displayValue']
      deaths = stats['deaths']['basic']['displayValue']
      average_lifespan = stats['averageLifespan']['basic']['displayValue']
      revives_given = stats['resurrectionsPerformed']['basic']['displayValue']
      revives_received = stats['resurrectionsReceived']['basic']['displayValue']
      suicides = stats['suicides']['basic']['displayValue']
      best_weapon = stats['weaponBestType']['basic']['displayValue']
      fastest_time = stats['fastestCompletionMs']['basic']['displayValue']
      kd_ratio = stats['killsDeathsRatio']['basic']['displayValue']
      highest_level = stats['highestCharacterLevel']['basic']['displayValue']
      highest_light = stats['highestLightLevel']['basic']['displayValue']
    rescue StandardError => e
      activities_cleared = '0'
      activities_entered = '0'
      completion_rate = '0'
      kills = '0'
      deaths = '0'
      average_lifespan = 'N/A'
      revives_given = '0'
      revives_received = '0'
      suicides = '0'
      best_weapon = '0'
      fastest_time = '0'
      kd_ratio = '0'
      highest_level = '0'
      highest_light = '0'
    end

    # get_items = Typhoeus::Request.new(
    #   "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{@character['characterBase']['peerView']['equipment'][0]['itemHash']}/",
    #   method: :get,
    #   headers: {"x-api-key" => ENV['API_TOKEN']}
    #   )

    # get_items.on_complete do |item_response|
    #     item_data = JSON.parse(item_response.body)
    #     @subclass_icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
    #     @subclass_name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
    # end

    stats = {
      'light_level' => light_level,
      'grimoire' => '0',
      'background' => background,
      'emblem' => emblem,
      'subclass_icon' => '',
      'subclass_name' => @subclass_name,
      'activities_cleared' => activities_cleared,
      'activities_entered' => activities_entered,
      'activity_completion_rate' => completion_rate,
      'kills' => kills,
      'deaths' => deaths,
      'average_lifespan' => average_lifespan,
      'revives_given' => revives_given,
      'revives_received' => revives_received,
      'suicides' => suicides,
      'best_weapon' => best_weapon,
      'fastest_time' => fastest_time,
      'kd_ratio' => kd_ratio,
      'highest_level' => highest_level,
      'highest_light' => highest_light
    }

    characters_stats << { 'player_name' => user.display_name, 'character_type' => character_type, 'character_stats' => stats }
    characters_stats = Hash[*characters_stats]
    characters_stats
end
end
