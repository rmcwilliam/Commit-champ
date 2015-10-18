require "httparty"
require "pry"

require "commitchamp/version"
require "commitchamp/github_api"

module Commitchamp
  class App
    def initialize
    end

    def run
      @user_data = []
      get_repo

      @results.each do |result|
        username = result["author"]["login"]
        additions = result["weeks"].inject(0) {|sum, key| sum + key["a"]} # must pass 0 to inject method to work?
        deletions = result["weeks"].inject(0) {|sum, key| sum + key["d"]}
        commits = result["weeks"].inject(0) {|sum, key| sum + key["c"]}
        total_commits = additions + deletions + commits 
        @user_data.push ({user: username, a: additions, d: deletions, c: commits, t: total_commits}) # Just create another array of hashes...
        #binding.pry
      end
      table(@user_data)
      sort_data
    end

    def sort_data
      puts "Would you like to sort the data by additions: a, deletions: d, or total commits: t?"
      puts "Please select a, d, or t"
      selection = STDIN.gets.chomp
      if selection == "a"
        data = @user_data.sort_by {|value| value[:a]}
        table(data)                                     
        #binding.pry
      end
      if selection == "d"
        data = @user_data.sort_by {|value| value[:d]}
        table(data)
      end
      if selection == "t"
        t = @user_data.sort_by {|value| value[:t]}
        table(data)
      end
      #binding.pry
    end                                              

    def table(data)
      data.each do |info|
        print(info[:user], info[:a], info[:d], info[:c], info[:t]) # Find fix: display looks bad
      end
    end

    def get_repo
      puts "Please enter your authentication token:"
      token = STDIN.gets.chomp
      auth = Githubapi.new(token)

      puts "Please enter the owner of the repo you would like to view:"
      owner = STDIN.gets.chomp

      puts "Please enter the repo you are interested in viewing:"
      repo = STDIN.gets.chomp

      @results = auth.get_contributions(owner, repo)
    end 
                                                       
  end
end

app = Commitchamp::App.new
app.run

## Contributions for 'owner/repo'

# Username      Additions     Deletions     Changes
# User 1            13534          2954        6249
# User 2             6940           913        1603

# Prompt the user for an auth token
# Ask the user what org/repo to get data about from github
# Print a table of contributions ranked in various ways
# Ask the user if they'd like to fetch another or quit.

# You don't have to track contributions by week, just sum them to get a total.
# Once all the contributions have been collected for a repo, offer to sort them by:
# 1) lines added 2) lines deleted 3) total lines changed 4) commits made

# Hash with usernames as keys for building up the table.

