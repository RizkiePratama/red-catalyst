class RedCatalyst < Sinatra::Application
  get '/transcode' do
    if params.include? 'action'
      if params['action'] == "new"
        @inputs = InputStream.all('live')
        @profiles = TranscodeProfile.all
        erb :'dashboard/transcode_form', :layout => :'layout/dashboard'
      elsif params['action'] == 'edit'
        if Transcode.exists?(params['id'])
          @inputs = InputStream.all('live')
          @profiles = TranscodeProfile.all
          @transcode_data = Transcode.find(params['id']).to_json
          erb :'dashboard/transcode_form', :layout => :'layout/dashboard'
        else
          flash[:alert] = 'Error! Profile Not Found'
          redirect '/transcode'
        end
      end
    else
      @transcodes = Transcode.get_all_sanitized
      @profiles = TranscodeProfile.all
      erb :'dashboard/transcode', :layout => :'layout/dashboard'
    end
  end

  post '/transcode' do
    if !params['action'] == "new"
      status 404
    end

    transcode = Transcode.new
    profile = TranscodeProfile.find(params['profile'])

    # Store Some info to DB
    transcode.name = "live-#{params['input']}_tp-#{profile.name.parameterize(separator: '-')}".downcase
    transcode.input_name = params['input']
    transcode.app_name = 'live'
    transcode.profile_id = params['profile']

    # Check if Same Transcode Configuration already running
    if !Transcode.where("name = ?", transcode.name).blank?
      flash[:alert] = "Transcode with same configuration Already Exists!"
      redirect '/transcode'
    end

    # Get Profile Info and start transcoding
    transcode.start_with_ffmpeg_param(profile.ffmpeg_param)

    if transcode.sanity_check
      flash[:notice] = "Successfully creating new Transcode Process for #{transcode.name}!"
    else
      flash[:alert] = "Somethings Wrong, Error while spawning Transcode Process!"
    end

    redirect '/transcode'
  end

  get '/transcode/restart' do
    transcode = Transcode.find(params['id'])

    # Get Profile Info
    profile = TranscodeProfile.find(transcode.profile_id)
    transcode.start_with_ffmpeg_param(profile.ffmpeg_param)

    if transcode.sanity_check
      flash[:notice] = "Successfully Restarting Transcode Process for #{transcode.name}!"
    else
      flash[:alert] = "Somethings Wrong, Error while spawning Transcode Process!"
    end

    redirect '/transcode'
  end

  get '/transcode/stop' do
    transcode = Transcode.find(params['id'])
    if transcode.kill
      flash[:notice] = "Successfully stop Transcode Process!"
    else
      flash[:warning] = "Failed to stop Transcode Process!"
    end
    redirect '/transcode'
  end

  get '/transcode/remove' do
    transcode = Transcode.find(params['id'])
    if transcode.remove
      flash[:notice] = "Successfully remove Transcode Profile!"
    else
      flash[:warning] = "Failed to stop Transcode Process!"
    end
    redirect '/transcode'
  end

  get '/transcode/preview' do
    @transcode = Transcode.find(params['id'])
    @input_stream = {}

    # Preview Playback
    @input_stream[:name] = params[:name]
    @input_stream[:url_flv] = "http://%s/red-catalyst/playback/transcode/%s.flv" % [request.host, @transcode.name]
    @input_stream[:url_rtmp] = "rtmp://%s:1940/transcode/%s" % [request.host, @transcode.name]
    erb :'dashboard/transcode_preview', :layout => :'layout/dashboard'
  end
end
