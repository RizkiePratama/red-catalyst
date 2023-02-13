class RedCatalystAPI < Sinatra::Application
  # Stream Function ENCDPOINT
  # =============================
  get '/stream' do
    content_type :json
    { "status" => "sucess",
      "message" => "Here's the transcode list",
      "content" => TargetStream.all
    }.to_json
  end

  get '/stream/checker' do
    content_type :json
    target_streams = TargetStream.where(status: "Streaming").to_a
    jobs = RedCatalystModule::RedCatalystJob.get_running_job

    jobs.each do | job |
      target_streams.each_with_index do | target, i |
        unless job["target"].include?("%s/%s" % [target.target_url, target.target_key])
          target.start_stream()
          if !target.sanity_check()
            target.status = "Error!"
            target.save
          end
        end
      end
    end

    { status: !target_streams.empty?, target: target_streams }.to_json
  end
end