# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
users = User.order(:created_at).take(6)
25.times do
  content = Faker::Lorem.sentence(1)
  users.each { |user| user.microposts.create!(content: content, game_type: 'Trials of Osiris') }
end
