# README

**NOTE: This app is currently in maintenance mode and will be replaced with a completely rewritten version. The latest (unreleased) version can be found at the following repos:**

* [destiny-client](https://github.com/destiny-aviato/destinder-client)

* [destiny-api](https://github.com/destiny-aviato/destinder-api)

## Getting started:

* Install Ruby, Rails, and Postgres on your machine ([guide for Mac OS](https://gorails.com/setup/osx/10.12-sierra))

* Clone the git repository:

    - In a terminal session, change to the directory you want the files to live in and run `git clone https://github.com/destiny-aviato/intense-spire.git`

    - Once that's done, change into the destinder directory

* Run `bundle install` in terminal

* For local development, run `figaro install`. This will create a file called /config/application.yml. Open it up and add the following lines:

```ruby
    CLIENT_ID: '<client_id>'
    CLIENT_SECRET: '<client_secret>'
    X_API_KEY: '<client api key>'
    REDIRECT_URL: "https://arcane-peak-29389.herokuapp.com/users/auth/bungie/callback" #for development
    API_TOKEN: '<client api key>' #this can be the same as the one above, you'll need it for API requests (for now)
```

>You will want to create an application on <https://www.bungie.net/en/Application/> to generate these keys. Select **OAuth Client Type = Confidential**, and add the same redirect_url above to the application settings. Select all permissions under scope except for "Move or equip Destiny gear and other items." Finally add `*` as the Origin header.

* Install [pow](http://pow.cx/) for subdomain api testing on development.
    - run `curl get.pow.cx | sh`
    - then `cd ~/.pow`
    - and finally `ln -s /path/to/myapp` (example: `~/workspace/destinder`)

* Now you should be able to run `rails db:migrate` (if it fails, try `rake db:create` first). This will create all of the databases

* If those have been successful, you should now be able to start the rails server by typing `rails server`. Navigate to http://localhost:3000 to see if it works.

## Contributing

We love and welcome all contribution requests! If you've either found a bug or have a feature you want added in, please create a pull request with a detailed comment outlining your changes (Follow [this guide](https://help.github.com/articles/fork-a-repo/)). Please also attach any screenshots of UI changes you may have made in the process as well. If you have any questions please file an issue on GitHub or send [send us an email](mailto:help@destinder.com). We plan on reviewing all pull requests within 2 weeks of submission. Thanks!
