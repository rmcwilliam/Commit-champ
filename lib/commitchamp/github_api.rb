require "httparty"
require "pry"


module Commitchamp  
  class Githubapi
    include HTTParty
    base_uri "https://api.github.com"
  
      def initialize(auth_token)
        @auth = {
        "Authorization" => "token #{auth_token}",
        "User-Agent"    => "HTTParty"
          }
      end

      def get_contributions(owner, repo)
        Githubapi.get("/repos/#{owner}/#{repo}/stats/contributors", :header => @auth)
      end
  end
end