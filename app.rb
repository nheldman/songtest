## SongTest RESTful API
# - all results (including error messages) returned as JSON (Accept header)

## requires
require 'sinatra/base'
require 'json'
require 'haml'
    
## logger
def logger
  @logger ||= Logger.new(STDOUT)
end

## SongTest application
class SongTest < Sinatra::Base
  set :methodoverride, true
  
  ## helpers
  def self.put_or_post(*a, &b)
    put *a, &b
    post *a, &b
  end
  
  before do  # Run this before ALL requests
    pass if request.request_method == "POST" && request.path_info == '/person'
    authenticate_user!
  end

  helpers do
    def authenticate_user!
      auth = Rack::Auth::Basic::Request.new(request.env)
      
      if auth.provided? && auth.basic? && auth.credentials
        person = Person.first(:email => auth.credentials[0])
      end

      if person && person.password == auth.credentials[1]
        return true
      else
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, json_status(401, "Not Authorized"))
      end
    end

    def json_status(code, reason)
      status code
      {
        :status => code,
        :reason => reason
      }.to_json
    end

    def accept_params(params, *fields)
      h = { }
      fields.each do |name|
        h[name] = params[name] if params[name]
      end
      h
    end
  end
end

# These requires must be at the bottom of the file
require_relative 'models/init'
require_relative 'routes/init'
