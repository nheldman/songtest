class SongTest < Sinatra::Base
  
  ## POST /vote/<random_id> - vote for randomly chosen song
  post %r{/vote/([a-z0-9]{12})} do
    random_id = params[:captures].first
    
    vote = Vote.first(:random_id => random_id)
    
    if !vote
      return json_status 400, "#{random_id} is not a valid random id"
    end
    
    json = JSON.parse(request.body.read.to_s)
    
    vote_updated = vote.update(json)
    
    if !vote_updated
      json_status 400, vote.errors.to_hash
    elsif vote[:rating] == nil
      # TODO: We should be able to validate rating conditionally for non-new records,
      # but that is not working as expected.  We should also be able to add errors:
      # vote.errors.add(:rating, 'Rating must not be blank')
      # But that's not really working as expected either...
      json_status 400, { :rating => ['Rating must not be blank'] }
    else # vote_updated 
      headers["Location"] = "/vote/#{vote.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      vote.to_json
    end
  end
  
  ## GET /vote/:id - return vote with specified id
  get '/vote/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Vote.valid_id?(params[:id])
      if vote = Vote.first(:id => params[:id].to_i)
        vote.to_json
      else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end

  ## PUT /vote/:id - change or create a vote
  # TODO: Should this be allowed?  If so, should we only allow rating/comment to be updated?
  put '/vote/:id', :auth => [ :admin ], :provides => :json do
    content_type :json

    if Vote.valid_id?(params[:id])
      if vote = Vote.first_or_create(:id => params[:id].to_i)
        json = JSON.parse(request.body.read.to_s)
        if vote.save
          vote.update(json)
          vote.to_json
        else
          json_status 400, vote.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /vote/:id - delete a specific vote
  # TODO: Should this be allowed?  If so, admins only?  Admins and voting user only?
  delete '/vote/:id', :auth => [ :admin ], :provides => :json do
    content_type :json

    if vote = Vote.first(:id => params[:id].to_i)
      vote.destroy!
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