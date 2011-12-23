require 'rubygems'
require './songtest'

Sinatra::Base.set :run, false
Sinatra::Base.set :environment, :production

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://production.db")
DataMapper.auto_upgrade!

run SongTest