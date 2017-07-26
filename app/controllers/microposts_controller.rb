class MicropostsController < ApplicationController
    before_action :correct_user, only: :destroy
    def index
        @microposts = Micropost.all.paginate(page: params[:page], per_page: 12)
        @micropost = current_user.microposts.build 
    end

    def create
        @micropost = current_user.microposts.build(micropost_params)
        case @micropost.game_type
        when "Trials of Osiris" 
            @micropost.user_stats = get_stats(current_user, "too")
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
      params.require(:micropost).permit(:content, :game_type, :user_stats)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
