require 'socket'

class RedCatalystAPI < Sinatra::Application

  # JOB Function ENCDPOINT
  # =============================
  post '/jobs/:func' do
    content_type :json
    if params['func'] == 'list'
      RedCatalystModule::RedCatalystJob.get_running_job.to_json
    elsif params['func'] == 'kill'
      status = false

      data = JSON.parse(request.body.read)
      if !data['pid'].nil?
        status = RedCatalystModule::RedCatalystJob.kill_job_by_pid(data['pid'])
      elsif !data['target'].nil?
        status = RedCatalystModule::RedCatalystJob.kill_job_by_target(data['target'])
      end

      if status
        { "status" => "success",
          "message" => "Success Kiling Job for Target %s" % params['target'] }.to_json
      else
        { "status" => "failed",
          "message" => "Failed Kiling Job for Target %s\nReason Unknown, Please Check Logs on Red Catalyst Process" % params['target'] }.to_json
      end
    else
      { "status" => "invalid",
        "message" => "Wrong Arguments"}.to_json
    end
  end

  get '/overlay' do
    content_type :json
    { "status" => "sucess",
      "message" => "Here's the transcode list",
      "content" => Overlay.all
    }.to_json
  end

end
