require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/record' do
    @inputs = []

    if params.include? 'action'
      @inputs = InputStream.all('live')

      if params['action'] == "new"
        erb :'dashboard/record_form', :layout => :'layout/dashboard'
      elsif params['action'] == 'edit'
        if Record.exists?(params['id'])
          erb :'dashboard/record_form', :layout => :'layout/dashboard'
        else
          flash[:notice] = 'Error! Record Not Found'
          redirect '/record'
        end
      end
    else
      @records = Record.all
      erb :'dashboard/record', :layout => :'layout/dashboard'
    end
  end

  post '/record' do
    if params.include? 'action'
      rec = Record.new
      rec.path = ENV['RECORD_PATH']
      rec.status = "recording"
      rec.app_name = params['app']
      rec.input_name = params['input']
      rec.name = params['name']
      rec.save

      flash[:notice] = 'Success creating new Record Process!'
      redirect '/record'
    end
  end
end