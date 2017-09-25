class TeamStat < ApplicationRecord
  serialize :stats_data
  serialize :characters
  validates :display_name, presence: true

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

  def self.get_recent_games(membership_type, membership_id, character_id)
    games = []
    get_recent_games = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/Stats/ActivityHistory/#{membership_type}/#{membership_id}/#{character_id}/?mode=14&count=15&lc=en",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    game_data = JSON.parse(get_recent_games.body)
    game_data['Response']['data']['activities'].each do |game|
      game_kills = game['values']['kills']['basic']['value']
      game_deaths = game['values']['deaths']['basic']['value']
      game_kd = game['values']['killsDeathsRatio']['basic']['displayValue']
      game_kad = game['values']['killsDeathsAssists']['basic']['displayValue']
      game_standing = game['values']['standing']['basic']['value']
      game_date = game['period']

      game_info = {
        'kills' => game_kills,
        'deaths' => game_deaths,
        'kd_ratio' => game_kd,
        'kad_ratio' => game_kad,
        'standing' => game_standing,
        'game_date' => game_date
      }

      games << game_info
    end
    games
  end

  def self.get_activity(username)
    username.display_name.strip!

    user = username.display_name.include?(' ') ? username.display_name.gsub(/\s/, '%20') : username.display_name

    hydra = Typhoeus::Hydra.hydra
    @team = []

    get_membership = Typhoeus::Request.new(
      "https://www.bungie.net/d1/Platform/Destiny/SearchDestinyPlayer/#{username.membership_type}/#{user}/",
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_membership.on_complete do |membership_response|
      membership_data = JSON.parse(membership_response.body)
      @membership_id = membership_data['Response'][0]['membershipId']
      @real_name = membership_data['Response'][0]['displayName']

      get_characters = Typhoeus::Request.new(
        "https://www.bungie.net/d1/Platform/Destiny/#{username.membership_type}/Account/#{@membership_id}/",
        method: :get,
        headers: { 'x-api-key' => ENV['API_TOKEN'] }
      )

      get_characters.on_complete do |character_response|
        character_data = JSON.parse(character_response.body)
        # TODO: Making this call again later on for original search - need to cut it down at some point
        @last_character = character_data['Response']['data']['characters'][0]['characterBase']['characterId']

        get_recent = Typhoeus::Request.new(
          "https://www.bungie.net/d1/Platform/Destiny/Stats/ActivityHistory/#{username.membership_type}/#{@membership_id}/#{@last_character}/?mode=TrialsOfOsiris&count=1",
          method: :get,
          headers: { 'x-api-key' => ENV['API_TOKEN'] }
        )

        get_recent.on_complete do |recent_response|
          recent_data = JSON.parse(recent_response.body)
          @recent_game = recent_data['Response']['data']['activities'][0]['activityDetails']['instanceId']
          @searched_team = recent_data['Response']['data']['activities'][0]['values']['team']['basic']['value']
        end
        hydra.queue(get_recent)
      end

      hydra.queue(get_characters)
    end
    hydra.queue(get_membership)
    hydra.run

    # get pgcr
    get_pgcr = Typhoeus.get(
      "https://www.bungie.net/d1/Platform/Destiny/Stats/PostGameCarnageReport/#{@recent_game}/?lc=en",
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )
    pgcr_data = JSON.parse(get_pgcr.body)
    @players = []
    @characters_stats = []
    pgcr_data['Response']['data']['entries'].each do |x|
      @players << x
    end

    @players.each do |player|
      team = player['values']['team']['basic']['value']
      if team != @searched_team
        next
      else
        player_name = player['player']['destinyUserInfo']['displayName']
        player_membership_id = player['player']['destinyUserInfo']['membershipId']
        player_character = player['characterId']

        # get player characters
        get_player_characters = Typhoeus::Request.new(
          "https://www.bungie.net/d1/Platform/Destiny/#{username.membership_type}/Account/#{player_membership_id}/",
          method: :get,
          headers: { 'x-api-key' => ENV['API_TOKEN'] }
        )

        get_player_characters.on_complete do |character_response|
          character_data = JSON.parse(character_response.body)
          last_character = character_data['Response']['data']['characters'][0]

          character_id = last_character['characterBase']['characterId']
          character_type = last_character['characterBase']['classType']
          light_level = last_character['characterBase']['powerLevel']
          grimoire = last_character['characterBase']['grimoireScore']
          stat_dicipline = last_character['characterBase']['stats']['STAT_DISCIPLINE']['value']
          stat_intellect = last_character['characterBase']['stats']['STAT_INTELLECT']['value']
          stat_strength = last_character['characterBase']['stats']['STAT_STRENGTH']['value']
          stat_armor = last_character['characterBase']['stats']['STAT_ARMOR']['value']
          stat_agility = last_character['characterBase']['stats']['STAT_AGILITY']['value']
          stat_recovery = last_character['characterBase']['stats']['STAT_RECOVERY']['value']
          inventory = last_character['characterBase']['peerView']['equipment']
          @items = {}

          item_type = {
            0 => 'Subclass',
            1 => 'Helmet',
            2 => 'Gauntlets',
            3 => 'Chest Armor',
            4 => 'Leg Armor',
            5 => 'Class Item',
            6 => 'Primary Weapon',
            7 => 'Secondary Weapon',
            8 => 'Heavy Weapon',
            9 => 'Ship',
            10 => 'Sparrow',
            11 => 'Ghost',
            12 => 'emblem',
            13 => 'Shader',
            14 => 'Emote',
            15 => 'Horn',
            16 => 'Artifact',
            17 => 'emblem_background',
            18 => 'emblem'
          }

          @items['emblem_background'] = "https://www.bungie.net#{last_character['backgroundPath']}" # emblem background
          @items['emblem'] = "https://www.bungie.net/#{last_character['emblemPath']}"

          inventory.each_with_index do |item, index|
            get_items = Typhoeus::Request.new(
              "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{item['itemHash']}/",
              method: :get,
              headers: { 'x-api-key' => ENV['API_TOKEN'] }
            )

            get_items.on_complete do |item_response|
              item_data = JSON.parse(item_response.body)
              icon = "https://www.bungie.net#{item_data['Response']['data']['inventoryItem']['icon']}"
              name = item_data['Response']['data']['inventoryItem']['itemName']
              tier = item_data['Response']['data']['inventoryItem']['tierTypeName']
              type = item_data['Response']['data']['inventoryItem']['itemTypeName']
              item = {
                'Item Icon' => icon,
                'Item Name' => name,
                'Item Tier' => tier,
                'Item Type' => type
              }
              @items[item_type[index]] = item
            end

            hydra.queue(get_items)
          end

          get_trials_stats = Typhoeus::Request.new(
            "https://www.bungie.net/d1/Platform/Destiny/Stats/#{username.membership_type}/#{player_membership_id}/#{character_id}/?modes=14",
            method: :get,
            headers: { 'x-api-key' => ENV['API_TOKEN'] }
          )

          get_trials_stats.on_complete do |stat_response|
            stat_data = JSON.parse(stat_response.body)
            elo = get_elo(player_membership_id)

            if stat_data['Response']['trialsOfOsiris'] != {}
              kills = stat_data['Response']['trialsOfOsiris']['allTime']['kills']['basic']['value']
              deaths = stat_data['Response']['trialsOfOsiris']['allTime']['deaths']['basic']['value']
              assists = stat_data['Response']['trialsOfOsiris']['allTime']['assists']['basic']['value']
              games_played = stat_data['Response']['trialsOfOsiris']['allTime']['activitiesEntered']['basic']['value']
              games_won = stat_data['Response']['trialsOfOsiris']['allTime']['activitiesWon']['basic']['value']
              auto_rifle = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsAutoRifle']['basic']['value']
              fusion_rifle = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsFusionRifle']['basic']['value']
              hand_cannon = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsHandCannon']['basic']['value']
              machine_gun = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsMachinegun']['basic']['value']
              pulse_rifle = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsPulseRifle']['basic']['value']
              rocket_launcher = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsRocketLauncher']['basic']['value']
              scout_rifle = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsScoutRifle']['basic']['value']
              shotgun = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsShotgun']['basic']['value']
              sniper = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsSniper']['basic']['value']
              sub_machine_gun = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsSubmachinegun']['basic']['value']
              side_arm = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsSideArm']['basic']['value']
              sword = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsSword']['basic']['value']
              melee = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsMelee']['basic']['value']
              grenades = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsGrenade']['basic']['value']
              super_kills = stat_data['Response']['trialsOfOsiris']['allTime']['weaponKillsSuper']['basic']['value']
              ability_kills = stat_data['Response']['trialsOfOsiris']['allTime']['abilityKills']['basic']['value']
              longest_spree = stat_data['Response']['trialsOfOsiris']['allTime']['longestKillSpree']['basic']['value']
              weapon_best_type = stat_data['Response']['trialsOfOsiris']['allTime']['weaponBestType']['basic']['displayValue']
              longest_life = stat_data['Response']['trialsOfOsiris']['allTime']['longestSingleLife']['basic']['displayValue']
              total_activity_time = stat_data['Response']['trialsOfOsiris']['allTime']['totalActivityDurationSeconds']['basic']['displayValue']
              orbs_dropped = stat_data['Response']['trialsOfOsiris']['allTime']['orbsDropped']['basic']['displayValue']
              res_received = stat_data['Response']['trialsOfOsiris']['allTime']['resurrectionsReceived']['basic']['displayValue']
              res_performed = stat_data['Response']['trialsOfOsiris']['allTime']['resurrectionsPerformed']['basic']['displayValue']
              precision_kills = stat_data['Response']['trialsOfOsiris']['allTime']['precisionKills']['basic']['displayValue']
              average_lifespan = stat_data['Response']['trialsOfOsiris']['allTime']['averageLifespan']['basic']['displayValue']
              avg_kill_distance = stat_data['Response']['trialsOfOsiris']['allTime']['averageKillDistance']['basic']['displayValue']
              avg_death_distance = stat_data['Response']['trialsOfOsiris']['allTime']['averageDeathDistance']['basic']['value']
              win_rate = ((games_won / games_played).round(2) * 100).round

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
              super_kills = 0
              ability_kills = 0
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
              'auto_rifle' => auto_rifle,
              'fusion_rifle' => fusion_rifle,
              'hand_cannon' => hand_cannon,
              'machine_gun' => machine_gun,
              'pulse_rifle' => pulse_rifle,
              'rocket_launcher' => rocket_launcher,
              'scout_rifle' => scout_rifle,
              'shotgun' => shotgun,
              'sniper' => sniper,
              'Sub Machine Gun' => sub_machine_gun,
              'side_arm' => side_arm,
              'sword' => sword,
              'melee' => melee,
              'grenades' => grenades,
              'Super' => super_kills,
              'ability' => ability_kills,
              'longest_spree' => longest_spree,
              'best_weapon_type' => weapon_best_type,
              'Longest Life' => longest_life,
              'Orbs Dropped' => orbs_dropped,
              'revives_received' => res_received,
              'revives_performed' => res_performed,
              'precision_kills' => precision_kills,
              'average_life_span' => average_lifespan,
              'average_kill_distance' => avg_kill_distance,
              'Average Death Distance' => avg_death_distance
            }

            @stats = {
              'kills' => kills.round,
              'deaths' => deaths.round,
              'Assists' => assists.round,
              'kd_ratio' => kd,
              'kad_ratio' => kad,
              'Intellect' => stat_intellect,
              'Discipline' => stat_dicipline,
              'Strength' => stat_strength,
              'elo' => elo,
              'games_won' => games_won,
              'games_lost' => (games_played - games_won),
              'win_rate' => win_rate,
              'Armor' => stat_armor,
              'Agility' => stat_agility,
              'Recovery' => stat_recovery,
              'light_level' => light_level,
              'grimoire' => grimoire,
              'kill_stats' => kill_stats
            }

            @profile = User.where('lower(display_name) = ?', player_name.downcase).first
            badges = @profile.nil? ? 'N/A' : @profile.badges

            @team << { 'player_name' => player_name, 'character_type' => character_type, 'character_stats' => @stats, 'Character Items' => @items, 'Badges' => badges, 'recent_games' => get_recent_games(username.membership_type, player_membership_id, character_id) }
          end
          hydra.queue(get_trials_stats)
        end
        hydra.queue(get_player_characters)

      end
      hydra.run
    end
    index = @team.index { |x| x['player_name'].casecmp(username.display_name.downcase).zero? }
    @team[0], @team[index] = @team[index], @team[0] if index != 0
    @team
  end
end
