class SongTest < Sinatra::Base

  ## misc handlers: error, not_found, etc.
  get "*" do
    status 404
  end

  put_or_post "*" do
    status 404
  end

  delete "*" do
    status 404
  end

  not_found do
    json_status 404, "Not found"
  end

  error do
    json_status 500, env['sinatra.error'].message
  end

  # start the server if ruby file executed directly
  if app_file == $0
    set :environment, :development
    DataMapper.setup(:default, "sqlite3:development.db")
    DataMapper.auto_upgrade!
    run!
  end
end