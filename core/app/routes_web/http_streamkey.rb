require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/streamkey' do
    @streamkey = StreamKey.all
    erb :'dashboard/streamkey', :layout => :'layout/dashboard'
  end

  get '/streamkey/new' do
    @streamkey = StreamKey.all
    erb :'dashboard/streamkey_new', :layout => :'layout/dashboard'
  end

  post '/streamkey/new' do
    # Check if Contain White Space
    if params['stream_key'].match(/\s/)
      flash[:alert] = "Error: Can't save Stream Key because it contain a whitespace"
      redirect '/streamkey'
    end

    # Check IF Stream Key Already Exists
    if !StreamKey.where("key = ?", params['stream_key']).blank?
      flash[:alert] = "Stream Key with same name Already Exists!"
    else
      sk = StreamKey.new
      sk.key = params['stream_key']
      sk.app = params['app_name']
      sk.save
      flash[:notice] = "Sucessfuly Create new Stream Key!"
    end

    redirect '/streamkey'
  end

  get '/streamkey/remove' do
    sk = StreamKey.where("key = ?", params['stream_key'])
    sk.destroy_all
    flash[:notice] = "Successfully remove Stream Key \"%s\"!" %  params['stream_key']

    redirect '/streamkey'
  end
end