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
        total_lines_changed = additions + deletions  
        @user_data.push ({user: username, a: additions, d: deletions, c: commits, t: total_lines_changed}) # Just create another array of hashes...
      end
      puts "\n\n"
      table(@user_data)
      puts "\n\n"
      sort_data
      options
    end

    def sort_data
      puts "Would you like to sort the data by additions: (a), deletions: (d), or total lines changed: (t)?\n\n"
      puts "Please select: ( a ), ( d ), or ( t ) if you would like to sort, otherwise selct ( o )"
      selection = STDIN.gets.chomp.downcase
      if selection == "a"
        data = @user_data.sort_by {|value| value[:a]}
        table(data)                                     
      end
      if selection == "d"
        data = @user_data.sort_by {|value| value[:d]}
        table(data)
      end
      if selection == "t"
        data = @user_data.sort_by {|value| value[:t]}
        table(data)
      end
      if selection == "o"
        options
      end
      puts "\n\n"
     options
    end                                              

    def table(data)
      printf("%-20s%10s%10s%10s%22s\n", "Username","Additions","Deletions","Commits","Total Lines Changed")
      data.each do |info|
        printf("%-20s%08s%08s%11s%14s\n", info[:user], info[:a], info[:d], info[:c], info[:t]) 
      end
    end
    
    def options
      puts "Would you like to sort the data differently: ( s ), select another repo: ( r ), or quit: ( q )"
      option = STDIN.gets.chomp.downcase
      if option == "s"
        sort_data
      end
      if option == "r"
        run
      end
      if option == "q"
        exit
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


