desc "Remove DB records"
puts "removing old LFG posts"
task delete_10_minutes_old: :environment do
    Micropost.where(['created_at < ?', 10.minutes.ago]).destroy_all
    PlayerStat.destroy_all
  end
  