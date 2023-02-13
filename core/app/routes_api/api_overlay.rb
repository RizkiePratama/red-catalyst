class RedCatalystAPI < Sinatra::Application
    get '/overlay/:id' do
        content_type :json
        overlay = Overlay.find(params['id'])
        overlay['path'] = overlay['path'].split('/')[-2,2].join('/')
        overlay.to_json
    end
end