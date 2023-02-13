require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/stream' do
    @active_stream = TargetStream.get_all_sanitized
    @transcodes = Transcode.get_all_sanitized
    erb :'dashboard/stream', :layout => :'layout/dashboard'
  end

  get '/stream/new' do
    @transcodes = Transcode.all
    @transcode_profiles = TranscodeProfile.all
    erb :'dashboard/stream_form', :layout => :'layout/dashboard'
  end

  post '/stream/new' do
    ts = TargetStream.new
    ts.assign_from_param(params)
    ts.start_stream()

    if ts.sanity_check
      flash[:notice] = "Successfully creating new Stream Process!"
    else
      flash[:alert] = "Somethings Wrong, Error while spawning Stream Process!"
      ts.destroy
    end

    redirect '/stream'
  end

  get '/stream/edit' do
    @target_stream = TargetStream.find(params['id'])
    if @target_stream.status == "Streaming"
      flash[:alert] = "Can't Modify, Stream is still active!"
      redirect '/stream'
    else
      @transcodes = Transcode.all
      @transcode_profiles = TranscodeProfile.all
      @transcode_profiles = TranscodeProfile.all
      erb :'dashboard/stream_form', :layout => :'layout/dashboard'
    end
  end

  post '/stream/edit' do
    ts = TargetStream.find(params['id'])
    ts.assign_from_param(params)
    ts.save

    flash[:notice] = "Successfully modify Stream Profile!"
    redirect '/stream'
  end

  get '/stream/reconnect' do
    stream = TargetStream.find(params['id'])
    stream.start_stream

    if stream.sanity_check
      flash[:notice] = "Successfully starting Stream Process!"
      stream.status = "Streaming"
    else
      flash[:alert] = "Somethings Wrong, Error while spawning Stream Process!"
      stream.status = "Streaming"
    end

    stream.save
    redirect '/stream'
  end

  get '/stream/stop' do
    stream = TargetStream.find(params['id'])
    if RedCatalystModule::RedCatalystJob.kill_job_by_pid(stream.pid)
      stream.status = "Stoped"
      flash[:notice] = "Successfully stop stream Process!"
    else
      stream.status = "Error!"
      flash[:alert] = "Failed to stop stream Process! Please check Logs!"
    end

    stream.save
    redirect '/stream'
  end

  get '/stream/remove' do
    stream = TargetStream.find(params['id'])
    RedCatalystModule::RedCatalystJob.kill_job_by_pid(stream.pid)
    stream.destroy
    redirect '/stream'
  end
end
