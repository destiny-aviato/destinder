desc 'Remove DB records'
puts 'removing old records'
task delete_10_minutes_old: :environment do
  Micropost.where(['created_at < ?', 2.days.ago]).destroy_all
  PlayerStat.destroy_all
  TeamStat.destroy_all
end
