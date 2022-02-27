require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    has_many :musics
    has_many :favorites
    has_many :favorite_musics, through: :favorites, source: :music
end

class Music < ActiveRecord::Base
    belongs_to :user
    has_many :favorites
    has_many :favorite_users, through: :favorites, source: :user
end

class Favorite < ActiveRecord::Base
    belongs_to :user
    belongs_to :music
end
