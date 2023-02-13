require 'sinatra'
require 'sinatra/activerecord'
require 'usagewatch_ext'
require 'require_all'

class RedCatalyst < Sinatra::Application
    set :port, 8085
    set :public_folder, Proc.new { File.join(root, "public") }
    set :thumbor_folder, Proc.new { File.join(root, "public/Thumbor") }
    set :overlay_folder, Proc.new { File.join(root, "public/Overlay") }
    set :static_cache_control, [:thumbor_folder, max_age:0]
    set :database_file, '../config/database.yml'
    set :session_secret, ENV['SESSION_SECRET']
    enable :sessions

    helpers do
        def restricted!
            return if authorized?
            redirect '/login'
        end

        def authorized?
            !!session[:user_id]
        end

        def current_user
            User.find_by(:id => session[:user_id])
        end
    end

    before do
        restricted! if request.path_info != "/login" && request.path_info != "/input/generate-thumb"
    end
end

require_all 'app/routes_web'
require_all 'app/models'
require_all 'app/helper'
require_all 'module'