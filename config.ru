require 'rubygems'
require './app'

Sinatra::Base.set :run, false
Sinatra::Base.set :environment, :production

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3:production.db")
DataMapper.finalize
DataMapper.auto_migrate!

run SongTest