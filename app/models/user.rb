class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:bungie]

  def email_required?
    false
  end
  
  def password_required?
    false
  end

  def self.from_omniauth(auth)
     where(provider: auth.provider, :uid => auth.uid).first_or_create do |user|
      user.membership_id = auth.info.membership_id
      user.display_name  = auth.info.display_name
      user.unique_name   = auth.info.unique_name
      user.profile_picture  = "https://www.bungie.net/#{auth.extra.bungieNetUser["profilePicturePath"]}"
      user.about = auth.extra.bungieNetUser["about"]
      user.api_membership_id = auth.extra.destinyMemberships[0]["membershipId"]
      user.api_membership_type = auth.extra.destinyMemberships[0]["membershipType"]

      if auth.extra.bungieNetUser.key?("psnDisplayName")
        user.psn_display_name = auth.extra.bungieNetUser["psnDisplayName"]
      elsif auth.extra.bungieNetUser.key?("xboxDisplayName")
        user.xbox_display_name = auth.extra.bungieNetUser["xboxDisplayName"]
      end
      
  end
end

end
