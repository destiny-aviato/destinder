class TeamStatsController < ApplicationController
    def new
        @team_stat = TeamStat.new
      end
    
      def show  
        @team_stat = TeamStat.find(params[:id])
      end
    
      def create
        @team_stat = TeamStat.new(team_stat_params)
        if @team_stat.save
          begin
            @team_stat.stats_data = TeamStat.get_recent_activity(@team_stat)
            @team_stat.save
            redirect_to @team_stat
          rescue NoMethodError
            redirect_to request.referrer || root_url
            # redirect_to root_url
            flash[:error] = "Error: Player Not Found!"
          rescue StandardError => e
            redirect_to root_url
            flash[:error] = "Error: #{e}"
          end
        else
          render 'new'
        end
      end
    
      def get_stats(mode)
        begin
          case mode
          when "too"  
            begin
              TeamStat.get_trials_stats(@team_stat.display_name,@team_stat.membership_type)
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
      helper_method :get_stats
      
    
      private
      def team_stat_params
          params.require(:team_stat).permit(:display_name, :membership_type, :stats_data)
      end
      
end
