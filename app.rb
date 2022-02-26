require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'

require 'open-uri'
require 'net/http'
require 'json'

enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
end

get '/' do
    @contents = User.all.order('id desc')
    if current_user.nil?
        @usermusics = Music.none
    else
        @usermusics = current_user.musics
    end
    erb :index
end

get '/signup' do
    erb :sign_up
end

get '/home' do
    erb :home
end

get '/search' do
    keyword = params[:keyword]
    uri = URI("https://itunes.apple.com/search")
    uri.query = URI.encode_www_form({ term: keyword, country: "JP", media: "music", limit: 10 })
    res = Net::HTTP.get_response(uri)
    returned_JSON = JSON.parse(res.body)
    @musics = returned_JSON["results"]
    
    
    erb :search
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect '/'
end

post '/signup' do
    img_url = ''
    if params[:file]
        img = params[:file]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        img_url = upload['url']
    end
    
    @user = User.create(name:params[:name], password:params[:password],
    password_confirmation:params[:password_confirmation],
    icon: img_url
    )
    if @user.persisted?
        session[:user] = @user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

post '/post' do
    current_user.musics.create(img: params[:img], artist: params[:artist], 
    album: params[:album], name: params[:name], sample: params[:sample], comment: params[:comment], user_name: current_user.name)
    redirect '/'
end
    