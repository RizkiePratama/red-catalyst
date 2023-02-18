class TargetStream < ActiveRecord::Base
    def self.get_all_sanitized
      target_streams = self.all
      target_streams.each do |stream|
        stream.sanity_check
      end
      return target_streams
    end

    def kill
        if RedCatalystModule::RedCatalystJob.kill_job_by_pid(self.pid)
            err_log_file = "/tmp/RedCatalystTranscode-%s.err" % self.name
            out_log_file = "/tmp/RedCatalystTranscode-%s.out" % self.name
            File.delete(err_log_file) if File.exist?(err_log_file)
            File.delete(out_log_file) if File.exist?(out_log_file)

            self.status = "Stoped"
            self.pid = nil
            self.save
        end
    end

    def assign_from_param(params)
        self.name = params['name']
        self.is_relay_from_input = params['is_relay']
        self.input_name = params['input_name']
        self.target_url = params['target_url']
        self.target_key = params['target_key']
        self.input_name = params['input_name']
        if self.is_relay_from_input
            self.app_name = 'live'
        else
            self.app_name = 'transcode'
        end
    end

    def start_stream()
        target = [self.target_url, '/', self.target_key].join()
        input = self.is_relay_from_input ? "live/#{input_name}" : input = "transcode/#{input_name}"

        self.pid = Process.fork do
          while true do
            system("ffmpeg -hide_banner -loglevel warning -i rtmp://0.0.0.0:1935/%s -c:v copy -c:a copy -f flv \"%s\"" % [ input, target ],
              :out => "/tmp/RedCatalyst-%s.out" % target.split("/").last.split("?").first,
              :err => "/tmp/RedCatalyst-%s.err" % target.split("/").last.split("?").first )
          end
        end

        Process.detach(self.pid)
        self.save
        return true
    end

    def sanity_check
        # Sanity Check Lvl 1
        # Check if Trancode actualy running
        # --------------------------------
        return false if self.pid.blank? # if Get here then it failing

        # Sanity Check Lvl 2,
        # Check if Trancode Process actualy
        # push the stream into Transcode Path
        begin
          Process.getpgid(self.pid)
          self.status ="Streaming"
          self.save
          return true
        rescue Errno::ESRCH
          self.kill
          return false
        end
    end
end
