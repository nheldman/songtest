class SongTest < Sinatra::Base
  
  ## GET /song - return all songs
  get '/song/?', :provides => :json do
    content_type :json
    
    if songs = Song.all
      songs.to_json
    else
      json_status 404, "Not found"
    end
  end
  
  ## GET /song/:id - return song with specified id
  get '/song/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Song.valid_id?(params[:id])
      if song = Song.first(:id => params[:id].to_i)
        song.to_json
      else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end

  ## POST /song/ - create new song
  post '/song/?', :provides => :json do
    content_type :json

    json = JSON.parse(request.body.read.to_s)
    
    song = Song.new(json)
    
    if song.save
      headers["Location"] = "/song/#{song.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      song.to_json
    else
      json_status 400, song.errors.to_hash
    end
  end

  ## PUT /song/:id - change or create a song
  put '/song/:id', :provides => :json do
    content_type :json

    if Song.valid_id?(params[:id])
      if song = Song.first_or_create(:id => params[:id].to_i)
        json = JSON.parse(request.body.read.to_s)
        if song.save
          song.update(json)
          song.to_json
        else
          json_status 400, song.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /song/:id - delete a specific song
  delete '/song/:id/?', :provides => :json do
    content_type :json

    if song = Song.first(:id => params[:id].to_i)
      song.destroy!
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.7
      status 204 # No content
    else
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.1.2
      # Note: section 9.1.2 states:
      #   Methods can also have the property of "idempotence" in that
      #   (aside from error or expiration issues) the side-effects of
      #   N > 0 identical requests is the same as for a single
      #   request.
      # i.e that the /side-effects/ are idempotent, not that the
      # result of the /request/ is idempotent, so I think it's correct
      # to return a 404 here.
      json_status 404, "Not found"
    end
  end
end