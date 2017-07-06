class MicropostsController < ApplicationController
    before_action :correct_user,   only: :destroy
    def index
        @microposts = Micropost.all.paginate(page: params[:page], per_page: 10)
        @micropost = current_user.microposts.build 
    end

    def create
        @micropost = current_user.microposts.build(micropost_params)
        @micropost.user.elo = Micropost.get_elo(@micropost.user.api_membership_id )
        @micropost.user.save!
        if @micropost.save
            flash[:success] = "Post created!"
            redirect_to microposts_path
        else
         render microposts_path
        end
    end

    def destroy
        @micropost.destroy
        flash[:success] = "Micropost deleted"
        redirect_to request.referrer || root_url
  end

    private

    def micropost_params
      params.require(:micropost).permit(:content)
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
