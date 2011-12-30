class SongTest < Sinatra::Base
  
  ## GET /winner - return all winners
  get '/winner', :provides => :json do
    content_type :json
    
    if winners = Winner.all
      winners.to_json
    else
      json_status 404, "Not found"
    end
  end

  ## GET /winner/:id - return winner with specified id
  get '/winner/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Winner.valid_id?(params[:id])
      if winner = Winner.first(:id => params[:id].to_i)
        winner.to_json
      else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end
  
  # TODO: Calculate the winner automatically for each month
  # One idea: add a POST '/winner/:month' resource.
  # This could be called by the client, and calculate the winner in that range
  # based on the song create date.  Ideally, a service would handle this
  # automatically.  If manual, a post to '/winner/102011' would calculate the
  # highest number of votes for all songs created between 10/1/2011 12:00:00 AM
  # and 10/31/2011 11:59:59 PM
end