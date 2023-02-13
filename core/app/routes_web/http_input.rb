require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  # Red Catalyst Landing
  get '/' do
    erb :'dashboard/index', :layout => :'layout/dashboard'
  end

  get '/assets' do
    erb :'dashboard/index', :layout => :'layout/dashboard'
  end

  get '/input/:app' do
    erb :'dashboard/input', :layout => :'layout/dashboard'
  end

  get '/input/:app/:name' do
    @input_stream = {}
    @active_stream = []

    # Preview Playback
    @input_stream[:name] = params[:name]
    @input_stream[:url_rtmp] = "rtmp://%s:1940/live/%s" % [request.host, params[:name]]
    @input_stream[:url_flv] = "http://%s/red-catalyst/playback/live/%s.flv" % [request.host_with_port, params[:name]]
    erb :'dashboard/input_preview', :layout => :'layout/dashboard'
  end

  post '/input/generate-thumb' do
    data = JSON.parse(request.body.read)
    thumb = RedCatalyst::Thumbor.new(data['app'], data['stream'], settings.thumbor_folder)
    if data['action'] == "on_publish"
      thumb.generate()
      status 200
      body '0'
    elsif data['action'] == "on_unpublish"
      thumb.stop()
      status 200
      body '0'
    end
  end
end