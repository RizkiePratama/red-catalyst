require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/embed' do
    @stats = InputStream.all('embed')
    erb :'dashboard/embed', :layout => :'layout/dashboard'
  end

  get '/embed/new' do
    erb :'dashboard/embed_form', :layout => :'layout/dashboard'
  end

  post '/embed/new' do
    es = EmbedStream.new
    es.url = params["embed_url"]
    es.name = params["name"]

    embed = Embed.new
    es.pid = embed.fromURL(es.url, es.sname)

    if(es.save)
      flash[:notice] = "Success adding new Embed Stream!"
    else
      flash[:alert] = "Failed to Create new Embed Stream!"
    end

    redirect '/embed/new'
  end

  get '/embed/:name' do
    @input_stream = {}
    @active_stream = []

    # Preview Playback
    @input_stream[:name] = params[:name]
    @input_stream[:url_flv] = "http://%s/red-catalyst/playback/embed/%s.flv" % [request.host, params[:name]]
    @input_stream[:url_rtmp] = "rtmp://%s:1940/live/%s" % [request.host, params[:name]]
    erb :'dashboard/input_preview', :layout => :'layout/dashboard'
  end
end