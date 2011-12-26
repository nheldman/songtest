class SongTest < Sinatra::Base
  ############################ GENRE ############################
  
  ## get /genre - return all genres
  get '/genre/?', :provides => :json do
    content_type :json
    
    if genres = Genre.all
      genres.to_json
    else
      json_status 404, "Not found"
    end
  end

  ## GET /genre/:id - return genre with specified id
  get '/genre/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Genre.valid_id?(params[:id])
      if genre = Genre.first(:id => params[:id].to_i)
        genre.to_json
      else
        json_status 404, "Not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Not found"
    end
  end
  
  ## POST /genre - create new genre
  post '/genre/?', :provides => :json do
    content_type :json

    json = JSON.parse(request.body.read.to_s)
    
    genre = Genre.new(json)
    if genre.save
      headers["Location"] = "/genre/#{genre.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      genre.to_json
    else
      json_status 400, genre.errors.to_hash
    end
  end
  
  ## PUT /genre/:id - change or create a person
  put '/genre/:id', :provides => :json do
    content_type :json

    if Genre.valid_id?(params[:id])
      if genre = Genre.first_or_create(:id => params[:id].to_i)
        genre.attributes = genre.attributes.merge(params)
        if genre.save
          genre.to_json
        else
          json_status 400, genre.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /genre/:id - delete a specific genre
  delete '/genre/:id/?', :provides => :json do
    content_type :json

    if genre = Genre.first(:id => params[:id].to_i)
      genre.destroy!
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