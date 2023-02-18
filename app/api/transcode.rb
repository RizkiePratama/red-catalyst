class RedCatalystAPI < Sinatra::Application
     # Transcode Function ENCDPOINT
  # =============================
  get '/transcode' do
    content_type :json
    { "status" => "sucess",
      "message" => "Here's the transcode list",
      "content" => Transcode.all
    }.to_json
  end

  post '/transcode' do
    begin
      data = JSON.parse(request.body.read.gsub(/\s+/, ""))
    rescue JSON::ParserError => e
      return {
        "status" => "failed",
        "message" => e,
      }.to_json
    end

    transcode = RedCatalyst::Transcode.new(data["app"], data["input"])
    pid = transcode.start_with_options(data["options"])

    if pid
      content_type :json
      { "status" => "success",
        "message" => "Success make Transcoding for Input %s" % data['input'],
        "job_pid" => pid
      }.to_json
    else
      content_type :json
      { "status" => "failed",
        "message" => "Failed to do Transcoding",
      }.to_json
    end
  end
end