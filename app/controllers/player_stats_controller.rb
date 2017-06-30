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
      redirect_to @player_stat
      flash[:success] = "Successfully found user"
    else
      render 'new'
    end
  end

  private
  def player_stat_params
      params.require(:player_stat).permit(:display_name, :membership_type, :stats_data)
  end
  
end
