class HomeController < ApplicationController
    helper_method :get_stats
    
    def index
        puts "test"
        @stats = get_stats("too")
        @trials_map = get_map
    end    

    def index2
        puts "test"
        @stats = get_stats("too")
        @trials_map = get_map
    end

    def faq
    end

    def kota
    end

    def kurt
    end
    
    def brian
    end

    def alex
    end

    def get_stats(mode)
        begin
          case mode
          when "too"
            begin
              Rails.cache.fetch("user_trials_stats", expires_in: 2.minutes) do
                return current_user.get_trials_stats(current_user)
              end
            rescue NoMethodError
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
              "https://www.bungie.net/Platform/Destiny/2/Account/4611686018428388122/",
              method: :get,
              headers: {"x-api-key" => ENV['API_TOKEN']}
          )
      
  
          get_characters.on_complete do |character_response|  
              character_data = JSON.parse(character_response.body)
              last_character = character_data["Response"]["data"]["characters"][0]["characterBase"]["characterId"]
              get_last_activity = Typhoeus::Request.new(
                "https://www.bungie.net/Platform/Destiny/Stats/ActivityHistory/2/4611686018428388122/#{last_character}/?mode=14&count=1&lc=en&definitions=true",
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
