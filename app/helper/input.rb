require 'net/http'
require 'json'

class InputStream
  class << self
    def all(app_name)
        url = "http://0.0.0.0:1985/api/v1/streams/"
        res = Net::HTTP.get_response(URI.parse(url))
        stats_data = JSON.parse(res.body)
        stats_data = stats_data["streams"]
        inputs = []
        
        stats_data.each do | stream |
          if stream["app"] == app_name
            inputs.append(stream)
          end
        end

        return inputs
    end
  end
end