class MicropostsController < ApplicationController
    before_action :correct_user, only: :destroy

    def index
        @microposts = Micropost.where(nil).paginate(page: params[:page], per_page: 12)
        filtering_params(params).each do |key, value|
          @microposts = @microposts.public_send(key, value) if value.present?
        end
        @micropost = current_user.microposts.build 

        respond_to do |format|
            format.html { }
            format.js { }
        end
        
    end

    def create

        @micropost = current_user.microposts.build(micropost_params)
        case @micropost.game_type
        when "Trials of Osiris" 
            @micropost.user_stats = get_stats(current_user, "too")
        when "Wrath of the Machine"
            @micropost.user_stats = get_stats(current_user, "wrath")
        when "King's Fall"
            @micropost.user_stats = get_stats(current_user, "kings")
        when "Crota's End"
            @micropost.user_stats = get_stats(current_user, "crota")
        when "Vault of Glass"
            @micropost.user_stats = get_stats(current_user, "vog")
        end

        if @micropost.save
            respond_to do |format|
                # if the response fomat is html, redirect as usual
                format.html { redirect_to microposts_path }

                # if the response format is javascript, do something else...
                format.js { }
            end
        else
            respond_to do |format|
                format.js { render :js => "Materialize.toast('Whoops! Your post is too long.', 4000); " }
              end
        end
    end

    def destroy
        @microposts = Micropost.all.paginate(page: params[:page], per_page: 12)
        @micropost.destroy

        respond_to do |format|
            format.html { request.referrer || root_url }
            format.js { }
        end
        
    end

    def get_stats(user, mode)
        begin
            case mode
            when "too"  
                Micropost.get_trials_stats(user)
            when "wrath"
                Micropost.get_raid_stats(user, "wrath")
            when "kings"
                Micropost.get_raid_stats(user, "kings")
            when "crota"
                Micropost.get_raid_stats(user, "crota")
            when "vog"
                Micropost.get_raid_stats(user, "vog")
            end

        rescue NoMethodError => e 
            # redirect_to request.referrer || root_url
            redirect_to root_url
            flash[:error] = "Error: #{e}"
        end
    end
    helper_method :get_stats


    private

    def micropost_params
      params.require(:micropost).permit(:content, :game_type, :user_stats, :platform, :raid_difficulty)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

    def filtering_params(params)
        params.slice(:game_type, :raid_difficulty, :platform)
      end
end
