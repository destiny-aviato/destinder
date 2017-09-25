# Use this hook to configure merit parameters
Merit.setup do |config|
  # Check rules on each request or in background
  # config.checks_on_each_request = true

  # Define ORM. Could be :active_record (default) and :mongoid
  # config.orm = :active_record

  # Add application observers to get notifications when reputation changes.
  # config.add_observer 'MyObserverClassName'

  # Define :user_model_name. This model will be used to grand badge if no
  # `:to` option is given. Default is 'User'.
  # config.user_model_name = 'User'

  # Define :current_user_method. Similar to previous option. It will be used
  # to retrieve :user_model_name object if no `:to` option is given. Default
  # is "current_#{user_model_name.downcase}".
  # config.current_user_method = 'current_user'
end

# Create application badges (uses https://github.com/norman/ambry)
# badge_id = 0
# [{
#   id: (badge_id = badge_id+1),
#   name: 'just-registered'
# }, {
#   id: (badge_id = badge_id+1),
#   name: 'best-unicorn',
#   custom_fields: { category: 'fantasy' }
# }].each do |attrs|
#   Merit::Badge.create! attrs
# end

Merit::Badge.create!(
  id: 1,
  name: 'Donator',
  description: 'Donated at least $5!',
  custom_fields: {
    icon: '<i class="material-icons" style="float: left; font-size: 14px; line-height: 23px; padding-right: 4px; margin-left: -6px;">attach_money</i>',
    color: 'color: #FAFAFA; background-color: #2ecc71;'
  }
)

Merit::Badge.create!(
  id: 2,
  name: 'Architect',
  description: 'Site Developer',
  custom_fields: {
    icon: '<i class="material-icons" style="float: left; font-size: 14px; line-height: 23px; padding-right: 3px; margin-left: -8px;">developer_mode</i>',
    color: 'color: #FAFAFA; background-color: #2f3337;'
  }
)
Merit::Badge.create!(
  id: 3,
  name: 'Donator',
  description: 'Donated at least $50!',
  custom_fields: {
    icon: '<i class="material-icons" style="float: left; font-size: 14px; line-height: 23px; padding-right: 4px; margin-left: -6px;">attach_money</i>',
    color: 'color: #FAFAFA; background-color: #B4B8BC;'
  }
)

Merit::Badge.create!(
  id: 4,
  name: 'Sponsor',
  description: 'Donated at least $100!',
  custom_fields: {
    icon: '<i class="material-icons" style="float: left; font-size: 14px; line-height: 23px; padding-right: 4px; margin-left: -6px;">attach_money</i>',
    color: 'color: #FAFAFA; background-color: #FFCC01;'
  }
)

Merit::Badge.create!(
  id: 5,
  name: 'Veteran',
  description: 'One of the first 500 users on the site!',
  custom_fields: {
    icon: '<i class="fa fa-first-order" style="float: left; font-size: 14px; line-height: 23px; padding-right: 4px; margin-left: -6px;"></i>',
    color: 'color: #FAFAFA; background-color: #026670;'
  }
)
Merit::Badge.create!(
  id: 6,
  name: 'Cake Boss',
  description: 'Paid for half of our domain. Whoo..',
  custom_fields: {
    icon: '<i class="fa fa-birthday-cake" style="float: left; font-size: 14px; line-height: 23px; padding-right: 4px; margin-left: -6px;"></i>',
    color: 'color: #FAFAFA; background-color: #FF00A3;'
  }
)

Merit::Badge.create!(
  id: 7,
  name: 'Little Helper',
  description: 'Feedback contributor on Reddit',
  custom_fields: {
    icon: '<i class="fa fa-reddit-alien" style="float: left; font-size: 15px; line-height: 21px; padding-right: 7px; margin-left: -6px;"></i>',
    color: 'color: #FAFAFA; background-color: #FF4500;'
  }
)

Merit::Badge.create!(
  id: 8,
  name: 'Follower',
  description: 'Follower of Destinder on social media',
  custom_fields: {
    icon: '<i class="fa fa-users" style="float: left; font-size: 15px; line-height: 21px; padding-right: 7px; margin-left: -6px;"></i>',
    color: 'color: #FAFAFA; background-color: #1DA1F2;'
  }
)
