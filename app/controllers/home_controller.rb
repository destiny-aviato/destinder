class HomeController < ApplicationController
    helper_method :get_stats
    
    def index
        puts "test"
        @stats = get_stats("too")
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
    
    
end
