require 'rubygems'
require './songtest'

set :run, false
set :environment, :production

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://production.db")
DataMapper.auto_upgrade!

run SongTest