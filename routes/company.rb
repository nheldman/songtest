class SongTest < Sinatra::Base
  
  ## GET /company - return all companies
  get '/company', :provides => :json do
    content_type :json
    
    if companies = Company.all
      companies.to_json
    else
      json_status 404, "Not found"
    end
  end
  
  ## GET /company/:id - return company with specified id
  get '/company/:id', :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Company.valid_id?(params[:id])
      if company = Company.first(:id => params[:id].to_i)
        company.to_json
      else
        json_status 404, "Not found"
      end
    else
      json_status 400, "Id parameter must be an integer"
    end
  end
  
  ## GET /company/:id/prizes - return prizes submitted by company
  get '/company/:id/prizes', :provides => :json do
      content_type :json
      
      # check that :id param is an integer
      if Company.valid_id?(params[:id])
        if company = Company.first(:id => params[:id].to_i)
          prizes = Prize.all(:company_id => company.id)
          prizes.to_json
        else
          json_status 404, "Not found"
        end
      else
        json_status 400, "Id parameter must be an integer"
      end
  end
  
  ## POST /company/ - create new company
  post '/company/?', :provides => :json do
    content_type :json

    json = JSON.parse(request.body.read.to_s)
    
    company = Company.new(json)
    if company.save
      headers["Location"] = "/company/#{company.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      company.to_json
    else
      json_status 400, company.errors.to_hash
    end
  end

  ## PUT /company/:id - change or create a company
  put '/company/:id', :provides => :json do
    content_type :json

    if Company.valid_id?(params[:id])
      if company = Company.first_or_create(:id => params[:id].to_i)
        json = JSON.parse(request.body.read.to_s)
        #company = company.update(json)
        if company.save
          company.update(json)
          company.to_json
        else
          json_status 400, company.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /company/:id - delete a specific company
  delete '/company/:id', :provides => :json do
    content_type :json

    if company = Company.first(:id => params[:id].to_i)
      company.destroy!
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