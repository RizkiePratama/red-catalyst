class Transcode < ActiveRecord::Base
    has_many :target_streams
    has_one :transcode_profile

    def self.get_all_sanitized
      transcodes = self.all
      transcodes.each do |transcode|
        transcode.sanity_check
      end
      return transcodes
    end

    def kill
        if RedCatalystModule::RedCatalystJob.kill_job_by_pid(self.pid)
            err_log_file = "/tmp/RedCatalystTranscode-%s.err" % self.name
            out_log_file = "/tmp/RedCatalystTranscode-%s.out" % self.name
            File.delete(err_log_file) if File.exist?(err_log_file)
            File.delete(out_log_file) if File.exist?(out_log_file)
            self.pid = nil
            self.status = "Stoped"
            self.save

            # Find if Any Target Stream using this Transcode_ID
            # If Any, Destroy it as well
            ts = TargetStream.where(input_name: self.name)[0]
            ts.kill if !ts.nil?
            return true
        end
    end

    def remove
         # Find if Any Target Stream using this Transcode_ID
        # If Any, Destroy it as well
        ts = TargetStream.where(input_name: self.name)[0]
        if !ts.nil?
            ts.kill
            ts.destroy
        end

        self.kill
        self.destroy
        return true
    end

    def check_existing_target
        jobs = RedCatalystModule::RedCatalystJob.get_running_job
        jobs.each do | job |
            if job['target'].include? "rtmp://0.0.0.0:1935/transcode/#{self.name}"
                RedCatalystModule::RedCatalystJob.kill_job_by_pid(job['pid'])
            end
        end
    end

    def start_with_ffmpeg_param(ffmpeg_param)
        check_existing_target
        self.pid = Process.fork do
          while true do
          system("ffmpeg -hide_banner -loglevel warning -probesize 10M -analyzeduration 10M -re -i rtmp://0.0.0.0:1935/%s/%s %s -f flv \"rtmp://0.0.0.0:1935/transcode/%s\"" % [self.app_name, self.input_name, ffmpeg_param, self.name],
                    :out => "/tmp/RedCatalystTranscode-%s.out" % [self.name],
                    :err => "/tmp/RedCatalystTranscode-%s.err" % [self.name] )
          end
        end
        Process.detach(self.pid)
    end

    def start_with_options(option_str)
        check_existing_target
        ffmpeg_param = parse_option_to_ffmpeg_command(option)
        start_with_ffmpeg_param(ffmpeg_param)
    end

    def parse_option_to_ffmpeg_command(option)
        option = validate_option(option)
        option_str = ""

        # Filter Related Options
        option_str << "-vf scale=%s:%s -r %s " % [option["video_width"], option["video_height"], option["fps"]]

        # Video Encoding Options
        option_str << "-c:v %s " % option["video_encoding"]
        option_str << "-b:v %sk " % option["video_rate"]
        option_str << "-g 30 "
        option_str << "-profile:v %s " % option["encode_profile"]

        # Audio Encoding Options
        option_str << "-c:a %s " % option["audio_encoding"]
        option_str << "-b:a %sk " % option["audio_rate"]
        option_str << "-ar %s " % option["audio_freq"]

        return option_str
    end

    # Makesure no Empty Columns
    def validate_option(option)
        option["fps"]             = '30'      if option["fps"].empty?
        option["res_width"]       = '1280'    if option["res_width"].empty?
        option["res_height"]      = '720'     if option["res_height"].empty?
        option["vcodec"]          = 'libx264' if option["vcodec"].empty?
        option["vbitrate"]        = '2500'    if option["vbitrate"].empty?
        option["acodec"]          = 'aac'     if option["acodec"].empty?
        option["abitrate"]        = '128'     if option["abitrate"].empty?
        option["afreq"]           = '44100'   if option["afreq"].empty?
        return option
    end

    def sanity_check
        # Sanity Check Lvl 1
        # Check if Trancode actualy running
        # --------------------------------
        return false if self.pid.blank?

        # Sanity Check Lvl 2,
        # Check if Trancode Process actualy
        # push the stream into Transcode Path
        begin
          # Wait up to 10s if Stream still not visible on RTMP block
          3.times {
              break if !InputStream.all('transcode').empty?
              sleep 5
          }

          Process.getpgid(self.pid)
          self.status = "Transcoding"
          self.save
          return true
        rescue Errno::ESRCH
          self.kill
          return false
        end
    end
end
