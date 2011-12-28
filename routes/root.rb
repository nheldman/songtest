class SongTest < Sinatra::Base

  ############################ HOME ############################
  
  ## get / - return 'SongTest' as string
  get '/' do
    @title = 'SongTest'
    haml :root, :layout => :layout
  end
  
  ## get /person - return all people
  get '/person/?', :provides => :json do
    content_type :json
    
    if people = Person.all
      people.to_json
    else
      json_status 404, "Not found"
    end
  end
end