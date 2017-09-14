class HomeController < ApplicationController
    helper_method :get_stats
    
    def index

    end    

    def index2
        puts "test"
        @stats = get_stats("too")
    end

    def faq
    end

    def kota
    end

    def kurt
    end
    
    def brian
      puts "test"
      @stats = get_stats("too")
      
    end
    
    def brock
      puts "test"
      @stats = get_stats("too")
    end

    def alex
      puts "test"
      @stats = get_stats("too")
    end

    def application_error
    end

    def site_stats
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
            redirect_to request.referrer || root_url
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
