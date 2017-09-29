class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  def bungie
    Rails.logger.info '----------------------------------------------------------------------'
    Rails.logger.info "Received OAUTH request, sending redirect_uri with value: #{ENV['REDIRECT_URL']}"
    Rails.logger.info request.env['omniauth.auth'].to_s
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      @user.remember_me = true

      if @user.badges == []
        @user.add_badge(5) if @user.id <= 550
      end

      sign_in_and_redirect @user, event: :authentication

      # set_flash_message(:notice, :success, :kind => 'Bungie') if is_navigational_format?
    else
      session['devise.bungie_data'] = request.env['omniauth.auth']
      puts 'new user!'
      redirect_to root_path
      flash.delete(:notice)
    end
  rescue StandardError => e
    redirect_to application_error_path
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  def failure
    Rails.logger.info '----------------------------------------------------------------------'
    Rails.logger.info "Received OAUTH request, sending redirect_uri with value: #{ENV['REDIRECT_URL']}"
    Rails.logger.info request.env['omniauth.auth'].to_s
    redirect_to root_path
  end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
