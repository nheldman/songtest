class SongTest < Sinatra::Base
  
  ## GET /song - return all songs
  get '/song', :provides => :json do
    content_type :json
    
    if songs = Song.all
      songs.to_json
    else
      json_status 404, "Not found"
    end
  end
  
  ## POST /song/random - return a random song (that has not yet been voted for) with one-time-use random id
  post '/song/random', :provides => :json do    
    # TODO: Check that the current user and person_id match
    person_id = Person.first.id
    
    random_id = Song.random_id
    
    song = Song.no_votes_by_person_id_and_fewest_total_votes(person_id)
    
    vote = Vote.new(:song_id => song.id, :random_id => random_id, :person_id => person_id)
    if vote.save
      redirect "/song/#{random_id}"
    else
      json_status 400, vote.errors.to_hash
    end
  end
  
  ## GET /song/<random_id> - redirect from /song/random
  get %r{/song/([a-z0-9]{12})} do
    random_id = params[:captures].first
    
    vote = Vote.first(:random_id => random_id)
    
    if !vote
      return json_status 400, "#{random_id} is not a valid song id"
    end
    
    # TODO: If song.person_id !== current user id, return 400
    song = Song.get(:id => vote.song_id)
    song.to_json
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