module RedCatalystModule
  extend self

  class RedCatalystJob
    def initialize()
    end

    def self.get_running_job
      std = `pgrep -a ffmpeg`
      if std.nil?
        {'status' => 'success', 'message' => 'No Running Process'}
      end

      job_list = []
      jobs = std.to_s.split("\n")
      jobs.each do | lines |
        line_split = lines.split("ffmpeg")
        pid = line_split.first()
        line_split = line_split[1].split("-i")
        name = line_split[1].split("-c:v")[0].split("/").last().delete(' ')
        target_host = line_split.last().split("flv").last().delete(' ')
        job_list.append({"pid" => pid, "stream_name" => name,  "target" => target_host})
      end

      return job_list
    end

    def self.kill_job_by_target(target)
      job_list = get_running_job
      job_list.each do | job |
        if job['target'].include? target
          system('kill %s' % job['pid'] )
          return true
        end
      end
      return false
    end

    def self.kill_job_by_pid(pid)
      begin
        Process.kill("TERM",  pid.to_i)
        {"killed" => true, "message" => "Process with PID #{pid} is killed"}
      rescue Errno::ESRCH
        {"killed" => true, "message" => "There's no Process running with PID #{pid}"}
      end
    end
  end
end

