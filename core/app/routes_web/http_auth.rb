require 'open-uri'
require 'active_support/core_ext/hash'

class RedCatalyst < Sinatra::Application
  get '/user' do
    @users = User.all
    erb :'dashboard/user', :layout => :'layout/dashboard'
  end

  get '/user/new' do
    erb :'dashboard/user_new', :layout => :'layout/dashboard'
  end

  post '/user/new' do
    user = User.create(name: params[:user_name], full_name: params[:full_name], password: params[:password])
    session[:user_id] = user.id
    flash[:message] = "New user account has been created!"
    redirect '/user'
  end

  get '/login' do
    if authorized?
      redirect '/'
    else
      erb :'dashboard/login'
    end
  end

  post '/login' do
    user = User.find_by(name: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/'
    elsif params[:username].empty? || params[:password].empty?
        flash[:alert] = "Username or password cannot be blank. please try again."
        redirect '/login'
    else
      flash[:alert] = "Incorrect username or password. Please try again."
      redirect '/login'
    end
  end

  get '/logout' do
    session.destroy
    redirect to '/login'
  end

end