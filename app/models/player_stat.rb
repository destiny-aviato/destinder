class PlayerStat < ApplicationRecord

    validates :display_name, presence: true

    def self.collect_data(user, membership_type)
        
        user.downcase!
        
        if user.include? " "
            user.gsub!(/\s/,'%20')
        end


        response = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        data = JSON.parse(response.body)

        membership_id = data["Response"][0]["membershipId"]
        real_name =  data["Response"][0]["displayName"]

        response2 = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/1/Account/#{membership_id}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        data2 = JSON.parse(response2.body)

        return [JSON.pretty_generate(data2), real_name]
    end
end
