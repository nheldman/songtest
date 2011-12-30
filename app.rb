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

  # TODO: Authorization: this will return 401 for all person requests
  #before '/person/*' do  # If you just use "before do", it will be for ALL requests
  #  halt 401, "Not Authorized"
  #end
  
  ## helpers
  def self.put_or_post(*a, &b)
    put *a, &b
    post *a, &b
  end

  helpers do
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
