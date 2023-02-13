require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/whitelist' do
    @whitelists = Whitelist.all
    erb :'dashboard/whitelist', :layout => :'layout/dashboard'
  end

  get '/whitelist/new' do
    @whitelists = Whitelist.all
    erb :'dashboard/whitelist_new', :layout => :'layout/dashboard'
  end

  post '/whitelist/new' do
    # Check if Contain White Space
    if params['ip'].match(/\s/)
      flash[:alert] = "Error: Can't Whitelist Info because IP Address contain a whitespace"
      redirect '/whitelist'
    end

    # Check IF Whitelist IP Already Exists
    if !Whitelist.where("ip = ?", params['ip']).blank?
      flash[:alert] = "IP Address already Whitelisted!"
    else
      wl = Whitelist.new
      wl.name = params['name']
      wl.ip = params['ip']
      wl.desc = params['desc']
      wl.save
      flash[:notice] = "Sucessfuly Create new Whitelist Rule!"
    end

    redirect '/whitelist'
  end

  get '/whitelist/remove' do
    wl = Whitelist.find(params['id'])
    wl.destroy
    flash[:notice] = "Successfully remove Whitelist Rule for IP \"%s\"!" %  wl['ip']

    redirect '/whitelist'
  end
end