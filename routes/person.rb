class SongTest < Sinatra::Base
  
  # TODO: Roles.  For many routes, need to ensure that we only allow admins or the user matching the id
  ## GET /person - return all people
  get '/person', :auth => [ :admin ], :provides => :json do
    content_type :json
    
    if people = Person.all
      people.to_json
    else
      json_status 404, "Not found"
    end
  end
  
  ## GET /person/:id - return person with specified id
  get '/person/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Person.valid_id?(params[:id])
      if person = Person.first(:id => params[:id].to_i)
        if person.is_admin? || person == session[:user]
          person.to_json
        else
          json_status 401, "Not authorized"
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end
  
  ## GET /person/:id/songs - return songs submitted by person
  get '/person/:id/songs', :provides => :json do
      content_type :json
      
      # check that :id param is an integer
      if Person.valid_id?(params[:id])
        if person = Person.first(:id => params[:id].to_i)
          songs = Song.all(:person_id => person.id)
          songs.to_json
        else
          json_status 404, "Not found"
        end
      else
        json_status 400, "Id parameter must be an integer"
      end
  end
  
  ## GET /person/:id/votes - return votes submitted by person
  get '/person/:id/votes', :provides => :json do
      content_type :json
      
      # check that :id param is an integer
      if Person.valid_id?(params[:id])
        if person = Person.first(:id => params[:id].to_i)
          votes = Vote.all(:person_id => person.id)
          votes.to_json
        else
          json_status 404, "Not found"
        end
      else
        json_status 400, "Id parameter must be an integer"
      end
  end

  ## POST /person/ - create new person
  post '/person', :provides => :json do
    content_type :json

    json = JSON.parse(request.body.read.to_s)
    
    person = Person.new(json)
    if person.save
      headers["Location"] = "/person/#{person.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      person.to_json
    else
      json_status 400, person.errors.to_hash
    end
  end

  ## PUT /person/:id/email/:email - change a person's email
  put_or_post '/person/:id/email/:email', :provides => :json do
    content_type :json

    if Person.valid_id?(params[:id])
      if person = Person.first(:id => params[:id].to_i)
        person.email = params[:email]
        if person.save
          person.to_json
        else
          json_status 400, person.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## PUT /person/:id - change or create a person
  put '/person/:id', :provides => :json do
    content_type :json

    if Person.valid_id?(params[:id])
      if person = Person.first_or_create(:id => params[:id].to_i)
        json = JSON.parse(request.body.read.to_s)
        #person = person.update(json)
        if person.save
          person.update(json)
          person.to_json
        else
          json_status 400, person.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /person/:id - delete a specific person
  delete '/person/:id', :provides => :json do
    content_type :json

    if person = Person.first(:id => params[:id].to_i)
      person.destroy!
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