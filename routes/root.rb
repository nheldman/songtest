class SongTest < Sinatra::Base

  ############################ HOME ############################
  
  ## get / - return 'SongTest' as string
  get '/' do
    @title = 'SongTest'
    haml :root, :layout => :layout
  end

end