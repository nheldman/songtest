class SongTest < Sinatra::Base
 
  ## GET /prize - return all prizes
  get '/prize', :provides => :json do
    content_type :json
    
    if prizes = Prize.all
      prizes.to_json
    else
      json_status 404, "Not found"
    end
  end
  
  ## GET /prize/available - returns prizes not yet claimed
  get '/prize/available', :provides => :json do
    content_type :json
    
    available_prizes = Prize.all(:song_id => nil)
    available_prizes.to_json
  end
  
  ## GET /prize/:id - return prize with specified id
  get '/prize/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Prize.valid_id?(params[:id])
      if prize = Prize.first(:id => params[:id].to_i)
        prize.to_json
      else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end
  
  ## GET /prize/:id/wishes - return wishes for this prize
  get '/prize/:id/wishes', :provides => :json do
    content_type :json
      
    # check that :id param is an integer
    if Prize.valid_id?(params[:id])
      if prize = Prize.first(:id => params[:id].to_i)
        wishes = Wish.all(:prize_id => prize.id)
        wishes.to_json
    else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end
  
  ## POST /prize/ - create new prize
  post '/prize', :provides => :json do
    content_type :json

    json = JSON.parse(request.body.read.to_s)
    
    prize = Prize.new(json)
    if prize.save
      headers["Location"] = "/prize/#{prize.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      prize.to_json
    else
      json_status 400, prize.errors.to_hash
    end
  end

  ## PUT /prize/:id - change or create a prize
  put '/prize/:id', :provides => :json do
    content_type :json

    if Prize.valid_id?(params[:id])
      if prize = Prize.first_or_create(:id => params[:id].to_i)
        json = JSON.parse(request.body.read.to_s)
        if prize.save
          prize.update(json)
          prize.to_json
        else
          json_status 400, prize.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /prize/:id - delete a specific prize
  delete '/prize/:id', :provides => :json do
    content_type :json

    if prize = Prize.first(:id => params[:id].to_i)
      prize.destroy!
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