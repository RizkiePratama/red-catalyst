class CreateTranscodeProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :transcode_profiles do |t|
      t.string :name

      t.string :vcodec
      t.integer :res_width
      t.integer :res_height
      t.integer :fps
      t.integer :vbitrate

      t.string :acodec
      t.integer :afreq
      t.integer :abitrate

      t.boolean :has_overlay
      t.integer :overlay_id
      t.string :overlay_mode
      t.integer :overlay_pos_x
      t.integer :overlay_pos_y

      t.string :ffmpeg_param
    end

    # Populate DB With Default Profile
    # ====================================

    # 1080p
    profile = TranscodeProfile.new
    profile.name        = "RedCatalyst 1080p"
    profile.res_width   = "1920"
    profile.res_height  = "1080"
    profile.vcodec      = "libx264"
    profile.fps         = "30"
    profile.vbitrate    = "4000"
    profile.acodec      = "aac"
    profile.afreq       = "44100"
    profile.abitrate    = "128"

    profile.has_overlay = false
    profile.overlay_id = 0
    profile.overlay_mode = "stretched"
    profile.overlay_pos_x = 0
    profile.overlay_pos_y = 0

    profile.ffmpeg_param = "-c:v %s -b:v %sk -g %s -preset %s -c:a %s -b:a %sk -ar %s" % [ profile.vcodec, profile.vbitrate, profile.fps, 'veryfast', profile.acodec, profile.abitrate, profile.afreq ]
    profile.save

    # 720p
    profile = TranscodeProfile.new
    profile.name        = "RedCatalyst 720p"
    profile.res_width   = "1280"
    profile.res_height  = "720"
    profile.vcodec      = "libx264"
    profile.fps         = "30"
    profile.vbitrate    = "2000"
    profile.acodec      = "aac"
    profile.afreq       = "44100"
    profile.abitrate    = "128"

    profile.has_overlay = false
    profile.overlay_id = 0
    profile.overlay_mode = "stretched"
    profile.overlay_pos_x = 0
    profile.overlay_pos_y = 0

    profile.ffmpeg_param = "-c:v %s -b:v %sk -g %s -preset %s -c:a %s -b:a %sk -ar %s" % [ profile.vcodec, profile.vbitrate, profile.fps, 'veryfast', profile.acodec, profile.abitrate, profile.afreq ]
    profile.save
  end
end
