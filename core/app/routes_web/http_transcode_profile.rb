require 'sinatra/flash'
require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/transcode/profile' do
    if params.include? 'action'
      if params['action'] == "new"
        @overlays = Overlay.all
        erb :'dashboard/transcode_profile_form', :layout => :'layout/dashboard'
      elsif params['action'] == 'edit'
        # Chech if Profile is in use, Cant Overide Active Profile
        if !Transcode.where(profile_id: params['id'], status: "Transcoding").blank?
          flash[:alert] = "Can't Modify, Profile is in use!"
          redirect '/transcode/profile'
        end

        if TranscodeProfile.exists?(params['id'])
          @profile_data = TranscodeProfile.find(params['id']).to_json
          @overlays = Overlay.all

          erb :'dashboard/transcode_profile_form', :layout => :'layout/dashboard'
        else
          flash[:notice] = 'Error! Profile Not Found'
          redirect '/transcode/profile'
        end
      end
    else
      @transcode_profile = TranscodeProfile.all
      @overlays = Overlay.all
      erb :'dashboard/transcode_profile', :layout => :'layout/dashboard'
    end
  end

  get '/transcode/profile/remove' do
    # Remove from DB
    profile = TranscodeProfile.find(params['id'])
    profile.destroy

    if profile.destroyed?
      flash[:notice] = "Successfuly Remove Profile #{profile.name}!"
    else
      flash[:notice] = "Error! Unable to Remove Profile #{profile.name}!"
    end

    redirect '/transcode/profile'
  end

  # Adding And Modify Profile
  post '/transcode/profile' do
    if params['action'] == "new"
      profile = TranscodeProfile.new
      flash.next[:notice] = 'Success adding new transcode profile!'
    elsif params['action'] == "edit"
      profile = TranscodeProfile.find(params['id'])
      flash.next[:notice] = 'Success edditing transcode profile!'
    else
      status 404
    end

    profile.name        = params['name']
    profile.res_height  = params['height']
    profile.res_width   = params['width']
    profile.vcodec      = params['vcodec']
    profile.fps         = params['fps']
    profile.vbitrate    = params['vbitrate']
    profile.acodec      = params['acodec']
    profile.afreq       = params['afreq']
    profile.abitrate    = params['abitrate']

    if params['overlay_id'] == "none"
      profile.has_overlay = false
      profile.overlay_id = 0
      profile.overlay_mode = "stretched"
      profile.overlay_pos_x = 0
      profile.overlay_pos_y = 0
    else
      profile.has_overlay = true
      profile.overlay_id = params['overlay_id']
      profile.overlay_mode = params['overlay_mode']

      if profile.overlay_mode == "absolute"
        profile.overlay_pos_x = params['overlay_pos_x']
        profile.overlay_pos_y = params['overlay_pos_y']
      else
        profile.overlay_pos_x = 0
        profile.overlay_pos_y = 0
      end
    end

    filter_param = ""
    if profile.has_overlay
      overlay = Overlay.find(profile.overlay_id)

      scaling_v_filter = "[0:v]scale=%s:%s[vid];" % [profile.res_width, profile.res_height]
      scaling_o_filter = ""
      pos_o_filter = "[vid][wm]overlay=(W-w)/2:(H-h)/2"

      if profile.overlay_mode = "stretched"
        scaling_o_filter = "[1:v]format=argb,colorchannelmixer=aa=1,scale=%s:%s[wm];" % [profile.res_width, profile.res_height]
      elsif profile.overlay_mode = "center"
        scaling_o_filter = "[1:v]format=argb,colorchannelmixer=aa=1,scale=-1:%s[wm];" % profile.res_height
      elsif profile.overlay_mode = "absolute"
        scaling_o_filter = "[1:v]format=argb,colorchannelmixer=aa=1,scale=iw:ih[wm];"
        pos_o_filter = "[vid][wm]overlay=(W-w)/2:(H-h)/2"
      end

      filter_param = "-i %s -filter_complex \"%s%s%s\" " % [overlay.path, scaling_v_filter, scaling_o_filter, pos_o_filter]
    else
      filter_param = "-filter_complex scale=%s:%s " % [profile.res_width, profile.res_height]
    end

    # Encoder Specific Param
    encoder_param = ""
    if profile.vcodec == "h264_hevc"
    elsif profile.vcodec == "libx264"
    end

    # Join All Variables
    profile.ffmpeg_param = "%s-c:v %s -b:v %sk -g %s -preset %s %s-c:a %s -b:a %sk -ar %s" % [filter_param, profile.vcodec, profile.vbitrate, profile.fps, 'veryfast', encoder_param, profile.acodec, profile.abitrate, profile.afreq]

    profile.save
    redirect '/transcode/profile'
  end
end