class RedCatalystAPI < Sinatra::Application
  post '/auth/stream' do
    content_type :json
    data = JSON.parse(request.body.read)
    STDERR.puts data

    # Check If It's Local Push from Transcoder
    if data['tcUrl'].include?("0.0.0.0") || data['tcUrl'].include?("127.0.0.1")
      status 200
      body '0'
      return
    end

    # Check if It's for Other App and Exist on Database
    if !StreamKey.where("key = ?", data['stream']).blank?
      status 200
      body '0'
    else
      status 403
      { "status" => "Access Denied",
        "message" => "Invalid Stream Key"}.to_json
    end
  end

  post '/whitelist' do
    client = JSON.parse(request.body.read)
    whitelisted = Whitelist.with_reserved
    whitelisted.each do | whitelist |
      ip_seg = whitelist[:ip]
      if ip_seg != nil && client['ip'].include?(ip_seg.split('*')[0])
        status 200
        body '0'
        return
      end
    end

    status 403;
  end
end