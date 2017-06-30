class PlayerStat < ApplicationRecord

    def self.collect_data(user, membership_type)
        # data = WhateverRestClient.get(url_to_api, username: username)
        # // Do a bunch of stuff with your data to make it easy to iterate through and use on your view
        # response = Typhoeus.get(
        #     "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}",
        #     headers: {'x-api-key'=> "9803c9a1f6c943cd927e3cfcbef60475"}
        # )

        # # data = JSON.parse(response.body)
        # puts response.body

        response = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/#{membership_type}/#{user}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        data = JSON.parse(response.body)

        membership_id = data["Response"][0]["membershipId"]

        response2 = RestClient.get(
            "http://www.bungie.net/Platform/Destiny/1/Account/#{membership_id}",
             headers={"x-api-key" => ENV['API_TOKEN']}
        )

        data2 = JSON.parse(response2.body)

        return data2
    end
end
