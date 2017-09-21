module ApplicationHelper
  def materialize_class_for(flash_type)
    { success: 'notification is-success', error: 'notification is-danger', alert: 'notification is-info', notice: 'notification is-warning' }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      next unless message != true
      !message.empty?
      next if message.empty?
      concat(content_tag(:div, message, class: materialize_class_for(msg_type).to_s) do
        concat content_tag(:button, '', class: 'delete', data: { dismiss: 'alert' })
        concat "     #{message}"
      end)
    end
    nil
  end

  def trials_test(username)
    username.display_name.strip!

    user = username.display_name.include?(' ') ? username.display_name.gsub(/\s/, '%20') : username.display_name

    hydra = Typhoeus::Hydra.hydra

    # elo = get_elo(username.api_membership_id)

    get_characters = Typhoeus::Request.new(
      # "https://www.bungie.net/Platform/Destiny2/#{user.api_membership_type}/Profile/#{user.api_membership_id}/?components=Characters,205",
      'https://www.bungie.net/Platform/Destiny2/1/Profile/4611686018439345596/?components=Characters,205',
      method: :get,
      headers: { 'x-api-key' => ENV['API_TOKEN'] }
    )

    get_characters.on_complete do |character_response|
      character_data = JSON.parse(character_response.body)
      # last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]
      characters = []
      @characters_stats = []
      character_data['Response']['characters']['data'].each do |x|
        characters << x
      end

      characters.each do |x|
        character_id = x[0]
        character_type = x[1]['classType']
        light_level = x[1]['light']
        # grimoire = x["characterBase"]["grimoireScore"]
        # stat_dicipline = x["characterBase"]["stats"]["STAT_DISCIPLINE"]["value"]
        # stat_intellect = x["characterBase"]["stats"]["STAT_INTELLECT"]["value"]
        # stat_strength = x["characterBase"]["stats"]["STAT_STRENGTH"]["value"]
        # stat_armor = x["characterBase"]["stats"]["STAT_ARMOR"]["value"]
        # stat_agility = x["characterBase"]["stats"]["STAT_AGILITY"]["value"]
        # stat_recovery = x["characterBase"]["stats"]["STAT_RECOVERY"]["value"]
        #     inventory = x["characterBase"]["peerView"]["equipment"]
        #     items = Hash.new

        #     item_type = {
        #         0 => "Subclass",
        #         1 => "Helmet",
        #         2 => "Gauntlets",
        #         3 => "Chest Armor",
        #         4 => "Leg Armor",
        #         5 => "Class Item",
        #         6 => "Primary Weapon",
        #         7 => "Secondary Weapon",
        #         8 => "Heavy Weapon",
        #         9 => "Ship",
        #         10 => "Sparrow",
        #         11 => "Ghost",
        #         12 => "emblem",
        #         13 => "Shader",
        #         14 => "Emote",
        #         15 => "Horn",
        #         16 => "Artifact",
        #         17 => "emblem_background",
        #         18 => "emblem"
        #     }

        #     items["emblem_background"] = "https://www.bungie.net#{x['backgroundPath']}" #emblem background
        #     items["emblem"] = "https://www.bungie.net/#{x['emblemPath']}"

        #     inventory.each_with_index do |item, index|

        #         get_items = Typhoeus::Request.new(
        #             "https://www.bungie.net/d1/Platform/Destiny/Manifest/InventoryItem/#{item["itemHash"]}/",
        #             method: :get,
        #             headers: {"x-api-key" => ENV['API_TOKEN']}
        #             )

        #         get_items.on_complete do |item_response|
        #             item_data = JSON.parse(item_response.body)
        #             icon = "https://www.bungie.net#{item_data["Response"]["data"]["inventoryItem"]["icon"]}"
        #             name = item_data["Response"]["data"]["inventoryItem"]["itemName"]
        #             tier = item_data["Response"]["data"]["inventoryItem"]["tierTypeName"]
        #             type = item_data["Response"]["data"]["inventoryItem"]["itemTypeName"]
        #             item = {
        #                 "Item Icon" => icon,
        #                 "Item Name" => name,
        #                 "Item Tier" => tier,
        #                 "Item Type" => type
        #             }
        #             items[item_type[index]] = item
        #         end

        #         hydra.queue(get_items)

        #     end

        get_trials_stats = Typhoeus::Request.new(
          # "https://www.bungie.net/d1/Platform/Destiny/Stats/#{username.api_membership_type}/#{username.api_membership_id}/#{character_id}/?modes=14",
          'https://www.bungie.net/Platform/Destiny2/1/Account/4611686018439345596/Character/2305843009260359587/Stats/?modes=39',
          method: :get,
          headers: { 'x-api-key' => ENV['API_TOKEN'] }
        )

        get_trials_stats.on_complete do |stat_response|
          stat_data = JSON.parse(stat_response.body)

          if stat_data['Response']['trialsOfOsiris'] != {}
          # kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["kills"]["basic"]["value"]
          # deaths = stat_data["Response"]["trialsOfOsiris"]["allTime"]["deaths"]["basic"]["value"]
          # assists = stat_data["Response"]["trialsOfOsiris"]["allTime"]["assists"]["basic"]["value"]
          # games_played = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesEntered"]["basic"]["value"]
          # games_won = stat_data["Response"]["trialsOfOsiris"]["allTime"]["activitiesWon"]["basic"]["value"]
          # avg_life_span = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageLifespan"]["basic"]["displayValue"]
          # auto_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsAutoRifle"]["basic"]["value"]
          # fusion_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsFusionRifle"]["basic"]["value"]
          # hand_cannon = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsHandCannon"]["basic"]["value"]
          # machine_gun = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsMachinegun"]["basic"]["value"]
          # pulse_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsPulseRifle"]["basic"]["value"]
          # rocket_launcher = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsRocketLauncher"]["basic"]["value"]
          # scout_rifle = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsScoutRifle"]["basic"]["value"]
          # shotgun = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsShotgun"]["basic"]["value"]
          # sniper = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSniper"]["basic"]["value"]
          # sub_machine_gun = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSubmachinegun"]["basic"]["value"]
          # side_arm = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSideArm"]["basic"]["value"]
          # sword = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSword"]["basic"]["value"]
          # melee = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsMelee"]["basic"]["value"]
          # grenades = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsGrenade"]["basic"]["value"]
          # super_kills =  stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponKillsSuper"]["basic"]["value"]
          # ability_kills =  stat_data["Response"]["trialsOfOsiris"]["allTime"]["abilityKills"]["basic"]["value"]
          # longest_spree = stat_data["Response"]["trialsOfOsiris"]["allTime"]["longestKillSpree"]["basic"]["value"]
          # weapon_best_type = stat_data["Response"]["trialsOfOsiris"]["allTime"]["weaponBestType"]["basic"]["displayValue"]
          # longest_life = stat_data["Response"]["trialsOfOsiris"]["allTime"]["longestSingleLife"]["basic"]["displayValue"]
          # total_activity_time = stat_data["Response"]["trialsOfOsiris"]["allTime"]["totalActivityDurationSeconds"]["basic"]["displayValue"]
          # orbs_dropped = stat_data["Response"]["trialsOfOsiris"]["allTime"]["orbsDropped"]["basic"]["displayValue"]
          # res_received = stat_data["Response"]["trialsOfOsiris"]["allTime"]["resurrectionsReceived"]["basic"]["displayValue"]
          # res_performed = stat_data["Response"]["trialsOfOsiris"]["allTime"]["resurrectionsPerformed"]["basic"]["displayValue"]
          # precision_kills = stat_data["Response"]["trialsOfOsiris"]["allTime"]["precisionKills"]["basic"]["displayValue"]
          # average_lifespan = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageLifespan"]["basic"]["displayValue"]
          # avg_kill_distance = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageKillDistance"]["basic"]["displayValue"]
          # avg_death_distance = stat_data["Response"]["trialsOfOsiris"]["allTime"]["averageDeathDistance"]["basic"]["value"]
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
            'Average Life Span' => avg_life_span,
            'Auto Rifle' => auto_rifle,
            'Fusion Rifle' => fusion_rifle,
            'Hand Cannon' => hand_cannon,
            'Machine Gun' => machine_gun,
            'Pulse Rifle' => pulse_rifle,
            'Rocket Launcher' => rocket_launcher,
            'Scout Rifle' => scout_rifle,
            'Shotgun' => shotgun,
            'Sniper' => sniper,
            'Sub Machine Gun' => sub_machine_gun,
            'Side Arm' => side_arm,
            'Sword' => sword,
            'Melee' => melee,
            'Grenades' => grenades,
            'Super' => super_kills,
            'Ability' => ability_kills,
            'Longest Spree' => longest_spree,
            'Best Weapon Type' => weapon_best_type,
            'Longest Life' => longest_life,
            'Orbs Dropped' => orbs_dropped,
            'revives_received' => res_received,
            'revives_performed' => res_performed,
            'Precision Kills' => precision_kills,
            'Average Lifespan' => average_lifespan,
            'Average Kill Distance' => avg_kill_distance,
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
            'ELO' => elo,
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

          @characters_stats << { 'character_type' => character_type, 'character_stats' => @stats, 'Character Items' => items, 'recent_games' => get_recent_games(username, character_id) }
        end

        hydra.queue(get_trials_stats)
      end
    end

    hydra.queue(get_characters)
    hydra.run
    @characters_stats
  end

  def featured_users
    users = []
    User.all.sample(10).each do |x|
      users << x
    end
    users
  end

  def calculate_badges(stats, user)
    badges = []

    # variables
    elo = stats['character_stats']['ELO']['ELO']
    total_deaths = stats['character_stats']['deaths'].to_f
    wins = stats['character_stats']['games_won'].to_f
    losses = stats['character_stats']['games_lost'].to_f
    win_rate = stats['character_stats']['win_rate'].to_f
    pulse_rifle_kills = stats['character_stats']['kill_stats']['Pulse Rifle'].to_f
    hand_cannon_kills = stats['character_stats']['kill_stats']['Hand Cannon'].to_f
    scout_rifle_kills = stats['character_stats']['kill_stats']['Scout Rifle'].to_f
    auto_rifle_kills = stats['character_stats']['kill_stats']['Auto Rifle'].to_f
    fusion_rifle_kills = stats['character_stats']['kill_stats']['Fusion Rifle'].to_f
    sniper_rifle_kills = stats['character_stats']['kill_stats']['Sniper'].to_f
    rocket_launcher_kills = stats['character_stats']['kill_stats']['Rocket Launcher'].to_f
    machine_gun_kills = stats['character_stats']['kill_stats']['Machine Gun'].to_f
    sword_kills = stats['character_stats']['kill_stats']['Sword'].to_f
    sidearm_kills = stats['character_stats']['kill_stats']['Side Arm'].to_f
    shotgun_kills = stats['character_stats']['kill_stats']['Shotgun'].to_f
    ability_kills = stats['character_stats']['kill_stats']['Ability'].to_f
    melee_kills = stats['character_stats']['kill_stats']['Melee'].to_f
    revives_performed = stats['character_stats']['kill_stats']['revives_performed'].to_f
    revives_received = stats['character_stats']['kill_stats']['revives_received'].to_f
    total_revives = revives_performed + revives_received
    avg_kill_distance = stats['character_stats']['kill_stats']['Average Kill Distance'].to_f
    avg_life_span = stats['character_stats']['kill_stats']['Average Life Span'].to_f
    super_kills = stats['character_stats']['kill_stats']['Super'].to_f
    grenade_kills = stats['character_stats']['kill_stats']['Grenades'].to_f
    precision_kills = stats['character_stats']['kill_stats']['Precision Kills'].to_f
    killing_spree = stats['character_stats']['kill_stats']['Longest Spree'].to_f
    total_kills = auto_rifle_kills + hand_cannon_kills + pulse_rifle_kills + scout_rifle_kills + sniper_rifle_kills + shotgun_kills + fusion_rifle_kills + sidearm_kills + rocket_launcher_kills + machine_gun_kills + sword_kills

    unless user.nil?
      # streamer

      # elo master

      # beloved if rep > 90%

      # despised id rep < 30%

      # fight forever if spree is > 10
    end

    ### CHARACTER BADGES #######
    # weapon type badges
    if (sniper_rifle_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Sniper',
        'badge_description' => 'More than 1/3 of total weapon kills with a Sniper Rifle',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #f1c40f; border: 1px #f1c40f solid;'
      }
    end

    if (pulse_rifle_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Pulse',
        'badge_description' => 'More than 1/3 of total weapon kills with a Pulse Rifle',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #2ecc71; border: 1px #2ecc71 solid;'
      }
    end

    if (scout_rifle_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Scout',
        'badge_description' => 'More than 1/3 of total weapon kills with a Scout Rifle',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #9b59b6; border: 1px #9b59b6 solid;'
      }
    end
    if (hand_cannon_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Hand Cannon',
        'badge_description' => 'More than 1/3 of total weapon kills with a Hand Cannon',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #3498db; border: 1px #3498db solid;'
      }
    end
    if (fusion_rifle_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Fusion',
        'badge_description' => 'More than 1/3 of total weapon kills with a Fusion Rifle',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #34495e; border: 1px #34495e solid;'
      }
    end

    if (auto_rifle_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Auto',
        'badge_description' => 'More than 1/3 of total weapon kills with an Auto Rifle',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #FA8708; border: 1px #FA8708 solid;'
      }
    end

    if (sidearm_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Sidearm',
        'badge_description' => 'More than 1/3 of total weapon kills with a Sidearm',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #AA885F; border: 1px #AA885F solid;'
      }
    end

    if (shotgun_kills / total_kills).round(2) >= 0.33
      badges << {
        'badge_name' => 'Shotgun',
        'badge_description' => 'More than 1/3 of total weapon kills with a Shotgun',
        'badge_icon' => '<i class="fa fa-crosshairs" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #e74c3c; border: 1px #e74c3c solid;'
      }
    end

    # medic if revives performed is More than 2x received
    if (revives_performed >= (revives_received * 2)) && revives_performed != 0
      badges << {
        'badge_name' => 'Medic',
        'badge_description' => 'Performed More than 2x revives than received',
        'badge_icon' => '<i class="fa fa-medkit" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #FF3B3F; border: 1px #FF3B3F solid;'
      }
    end

    # survivor if average life span > 2mins

    # ability kills More than 20% of total kills
    if (ability_kills / stats['character_stats']['kills']).round(2) >= 0.20
      badges << {
        'badge_name' => 'Super Man',
        'badge_description' => '20%+ of total kills with abilities',
        'badge_icon' => '<i class="fa fa-superpowers" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #4484CE; border: 1px #4484CE solid;'
      }
    end

    # marksman if precicion kills are More than 35% of total weapon kills
    if (precision_kills / total_kills).round(2) >= 0.60
      badges << {
        'badge_name' => 'Marksman',
        'badge_description' => 'More than 60% of total weapon kills are precision kills',
        'badge_icon' => '<i class="fa fa-bullseye" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px; color: #FF3B3D;"></i>',
        'badge_color' => 'color: #212121; border: 1px #212121 solid;'
      }
    end

    # Fight Forever if avg Spree > 10
    if (killing_spree >= 10) && (killing_spree < 15)
      badges << {
        'badge_name' => 'Fight Forever',
        'badge_description' => 'Kill Spree Greater than 10',
        'badge_icon' => '<i class="fa fa-fire-extinguisher" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #FF3B3D; border: 1px #009EF9 solid;'
      }
    end

    # Army of One if avg Spree > 15
    if (killing_spree >= 15) && (killing_spree < 20)
      badges << {
        'badge_name' => 'ArmyOfOne',
        'badge_description' => 'Kill Spree Greater than 15',
        'badge_icon' => '<i class="fa fa-diamond " style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px; color: #5F523C;"></i>',
        'badge_color' => 'color: #DFBF93; border: 1px #374730 solid;'
      }
    end

    # Trials God of One if avg Spree > 15
    if killing_spree >= 20
      badges << {
        'badge_name' => 'Trials God',
        'badge_description' => 'Kill Spree Greater than 20',
        'badge_icon' => '<i class="fa fa-star" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px; color: #212121;"></i>',
        'badge_color' => 'color: #009EF9; border: 1px #00FEFC solid;'
      }
    end

    # camper if avg kill distance > 25
    if avg_kill_distance >= 25
      badges << {
        'badge_name' => 'Camper',
        'badge_description' => 'Kill Distance is greater than 25m',
        'badge_icon' => '<i class="fa fa-free-code-camp" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #AA885F; border: 1px #AA885F solid;'
      }
    end

    # rusher if kill distance < 20
    if (avg_kill_distance <= 20) && (avg_kill_distance > 0)
      badges << {
        'badge_name' => 'Rusher',
        'badge_description' => 'Kill Distance is less than 20m',
        'badge_icon' => '<i class="fa fa-fast-forward" style="float: left; white-space: nowrap; font-size: 12px; line-height: 21px; padding-right: 4px; margin-left: -6px;"></i>',
        'badge_color' => 'color: #FF4500; border: 1px #FF4500 solid;'
      }

    end
    badges
  end
end
