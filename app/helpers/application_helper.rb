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
    elo = stats['character_stats']['elo']['elo']
    total_deaths = stats['character_stats']['deaths'].to_f
    wins = stats['character_stats']['games_won'].to_f
    losses = stats['character_stats']['games_lost'].to_f
    win_rate = stats['character_stats']['win_rate'].to_f
    pulse_rifle_kills = stats['character_stats']['kill_stats']['pulse_rifle'].to_f
    hand_cannon_kills = stats['character_stats']['kill_stats']['hand_cannon'].to_f
    scout_rifle_kills = stats['character_stats']['kill_stats']['scout_rifle'].to_f
    auto_rifle_kills = stats['character_stats']['kill_stats']['auto_rifle'].to_f
    fusion_rifle_kills = stats['character_stats']['kill_stats']['fusion_rifle'].to_f
    sniper_rifle_kills = stats['character_stats']['kill_stats']['sniper'].to_f
    rocket_launcher_kills = stats['character_stats']['kill_stats']['rocket_launcher'].to_f
    machine_gun_kills = stats['character_stats']['kill_stats']['machine_gun'].to_f
    sword_kills = stats['character_stats']['kill_stats']['sword'].to_f
    sidearm_kills = stats['character_stats']['kill_stats']['side_arm'].to_f
    shotgun_kills = stats['character_stats']['kill_stats']['shotgun'].to_f
    ability_kills = stats['character_stats']['kill_stats']['ability'].to_f
    melee_kills = stats['character_stats']['kill_stats']['melee'].to_f
    revives_performed = stats['character_stats']['kill_stats']['revives_performed'].to_f
    revives_received = stats['character_stats']['kill_stats']['revives_received'].to_f
    total_revives = revives_performed + revives_received
    avg_kill_distance = stats['character_stats']['kill_stats']['average_kill_distance'].to_f
    avg_life_span = stats['character_stats']['kill_stats']['average_life_span'].to_f
    #  super_kills = stats["character_stats"]["kill_stats"]["Super"].to_f
    grenade_kills = stats['character_stats']['kill_stats']['grenades'].to_f
    precision_kills = stats['character_stats']['kill_stats']['precision_kills'].to_f
    killing_spree = stats['character_stats']['kill_stats']['longest_spree'].to_f
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
    if (ability_kills / stats['character_stats']['kills'].to_f).round(2) >= 0.20
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
