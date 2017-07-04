class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }


    def self.get_elo(membership_id)
    elo = ''
    response = RestClient.get(
            "https://api.guardian.gg/elo/#{membership_id}"
        )

    data = JSON.parse(response.body)

    data.each do |x| 
      if x["mode"] == 14
        elo = x["elo"]
        break
      end
    end

    return elo.round
  end
end
