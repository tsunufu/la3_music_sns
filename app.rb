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
    @usermusics = Music.all
    erb :index
end

get '/signup' do
    erb :sign_up
end

get '/home' do
    if current_user.nil?
        @useridmusics = Music.none
    else
        @useridmusics = current_user.musics
    end
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
    album: params[:album], name: params[:name], sample: params[:sample], comment: params[:comment], user_id: session[:user])
    redirect '/'
end

get '/post/:id/del' do
    music = Music.find(params[:id])
    music.destroy
    redirect '/'
end

get '/post/:id/edit' do
    @post = Music.find(params[:id])
    erb :edit
end

post '/post/:id/edit' do
    music = Music.find(params[:id])
    music.comment = params[:comment]
    music.save!
    redirect '/'
end

get '/post/:id/like' do
    if Favorite.find_by(user_id: session[:user], music_id: params[:id]).nil?
        Favorite.create(user_id: session[:user], music_id: params[:id])
    end
    redirect '/home'
end

get '/post/:id/like_del' do
    like = Favorite.find_by(user_id: session[:user], music_id: params[:id])
    like.delete
    redirect '/home'
end
