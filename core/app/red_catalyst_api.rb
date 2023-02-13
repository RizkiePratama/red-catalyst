require 'sinatra'
require 'sinatra/activerecord'
require 'usagewatch_ext'
require 'require_all'

class RedCatalystAPI < Sinatra::Application
    set :database_file, '../config/database.yml'
end

require_all 'app/routes_api'
require_all 'app/models'
require_all 'app/helper'
require_all 'module'