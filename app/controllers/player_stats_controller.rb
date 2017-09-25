class PlayerStatsController < ApplicationController
  def new
    @player_stat = PlayerStat.new
  end

  def show
    @player_stat = PlayerStat.find(params[:id])
  end

  def create
    @player_stat = PlayerStat.new(player_stat_params)
    if @player_stat.save
      begin
        resp = PlayerStat.collect_data(@player_stat.display_name, @player_stat.membership_type)
        @player_stat.stats_data = resp[0]
        @player_stat.characters = resp[1]
        # @player_stat.display_name = resp[2]
        @player_stat.save
        redirect_to @player_stat
      rescue NoMethodError
        redirect_to request.referer || root_url
        # redirect_to root_url
        flash[:error] = 'Error: Player Not Found!'
      rescue StandardError => e
        redirect_to root_url
        flash[:error] = "Error: #{e}"
      end
    else
      render 'new'
    end
  end

  def get_stats(mode)
    case mode
    when 'too'
      begin
        PlayerStat.get_trials_stats(@player_stat.display_name, @player_stat.membership_type)
      rescue StandardError => e
        return nil
      end
    end
  rescue NoMethodError
    redirect_to request.referer || root_url
    flash[:error] = 'Error: Player Not Found!'
  rescue StandardError => e
    redirect_to root_url
    flash[:error] = "Error: #{e}"
  end
  helper_method :get_stats

  private

  def player_stat_params
    params.require(:player_stat).permit(:display_name, :membership_type, :stats_data)
  end
end
