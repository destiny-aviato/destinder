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
    where(:uid => auth.uid).first_or_create do |user|
      user.membership_id = auth.info.membership_id
      user.display_name  = auth.info.display_name
      user.unique_name   = auth.info.unique_name
   end
  end
end
