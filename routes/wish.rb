class SongTest < Sinatra::Base
  
  ## POST /wish - create new wish
  post '/wish', :provides => :json do
    content_type :json

    json = JSON.parse(request.body.read.to_s)
    
    wish = Wish.new(json)
    if wish.save
      headers["Location"] = "/wish/#{wish.song_id}/#{wish.prize_id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      wish.to_json
    else
      json_status 400, wish.errors.to_hash
    end
  end
  
  ## DELETE /wish/:song_id/:prize_id - delete a specific wish
  delete '/wish/:song_id/:prize_id', :provides => :json do
    content_type :json

    if wish = Wish.first(:song_id => params[:song_id].to_i, :prize_id => params[:prize_id].to_i)
      wish.destroy!
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