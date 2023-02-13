require 'sinatra/flash'
require 'securerandom'
include FileUtils::Verbose

class RedCatalyst < Sinatra::Application
  get '/transcode/overlay' do
    if params.include? 'action'
      if params['action'] == "new"
        erb :'dashboard/transcode_overlay_form', :layout => :'layout/dashboard'
      elsif params['action'] == 'edit'
        if Overlay.exists?(params['id'])
          @overlay_data = Overlay.find(params['id']).to_json
          erb :'dashboard/transcode_overlay_form', :layout => :'layout/dashboard'
        else
          flash[:notice] = 'Error! Profile Not Found'
          redirect '/transcode/overlay'
        end
      end
    else
      @overlays = Overlay.all
      erb :'dashboard/transcode_overlay', :layout => :'layout/dashboard'
    end
  end

  get '/transcode/overlay' do
  end

  post '/transcode/overlay' do
    if params['action'] == "new"
      overlay = Overlay.new
      flash.next[:notice] = 'Success adding new overlay!'
    elsif params['action'] == "edit"
      overlay = Overlay.find(params['id'])
      rm(overlay.path)
      flash.next[:notice] = 'Success editing overlay!'
    else
      status 404
    end

    tempfile = params[:image][:tempfile]
    filename = "%s.%s" % [SecureRandom.hex(25), params[:image][:filename].rpartition('.').last]
    overlay.name = params['name']
    overlay.path = "%s/%s" % [settings.overlay_folder, filename]
    FileUtils.mkdir_p settings.overlay_folder
    cp(tempfile.path, overlay.path)
    overlay.save

    flash.next[:notice] = 'Success adding new overlay!'
    redirect '/transcode/overlay'
  end

  get '/transcode/overlay/remove' do
    # Check If Transcode Preset Use The Overlay
    profile = TranscodeProfile.where("overlay_id = #{params['id']}")
    overlay = Overlay.find(params['id'])

    if profile.empty?
      # Remove Stored Image
      begin
        rm(overlay.path)
      rescue Errno::ENOENT
        #LOG"<b>#{overlay.name}</b> file was not found in storage, but still Successfully Removed from Database."
      end

      # Remove from DB
      overlay.destroy

      if overlay.destroyed?
        flash.next[:notice] = "Successfuly Remove Overlay #{overlay.name}!"
      else
        flash.next[:notice] = "Error! Unable to Remove Overlay #{overlay.name}!"
      end
    else
      flash.next[:notice] = "Unable to Remove Overlay #{overlay.name} because is still used by Transcode Profile!"
    end

    redirect '/transcode/overlay'
  end
end