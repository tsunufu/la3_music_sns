require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'

enable :sessions

get '/' do
    erb :index
end

get '/signup' do
    erb :sign_up
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

post '/signup' do
    @user = User.create(name:params[:name], password:params[:password],
    password_confirmation:params[:password_confirmation])
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end