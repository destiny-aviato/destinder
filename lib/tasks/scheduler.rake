desc "Removing old LFG posts"
task delete_15_minutes_old: :environment do
    MicroPost.where(['created_at < ?', 15.minutes.ago]).destroy_all
  end