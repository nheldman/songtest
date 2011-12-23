## SongTest
# RESTful API example
# - all results (including error messages) returned as JSON (Accept header)

## requires
require 'sinatra/base'
require 'json'
require 'time'
require 'pp'

### datamapper requires
require 'data_mapper'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'

## model
### helper modules
#### StandardProperties
module StandardProperties
  def self.included(other)
    other.class_eval do
      property :id, other::Serial
      property :created_at, DateTime
      property :updated_at, DateTime
    end
  end
end

#### Validations
module Validations
  def valid_id?(id)
    id && id.to_s =~ /^\d+$/
  end
end

### Person
class Person
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :first_name, String, :required => true
  property :last_name, String, :required => true
  property :email, String, :required => true
  
  #def to_json(*a)
  #  {
  #    'first_name' => self.first_name,
  #    'last_name' => self.last_name,
  #    'email' => self.email
  #  }.to_json(*a)
  #end
end

## set up db
ENV['RACK_ENV'] = 'test'
env = ENV["RACK_ENV"]
puts "RACK_ENV: #{env}"
if env.to_s.strip == ""
  abort "Must define RACK_ENV (used for db name)"
end

case env
when "test"
  DataMapper.setup(:default, "sqlite3::memory:")
else
  DataMapper.setup(:default, "sqlite3:#{ENV["RACK_ENV"]}.db")
end

## create schema if necessary
DataMapper.auto_upgrade!

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

  ## get / - return 'SongTest' as string
  get '/' do
    'SongTest'
  end
  
  ## get /person - return all people
  get '/person/?', :provides => :json do
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
        person.to_json
      else
        json_status 404, "Not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Not found"
    end
  end

  ## POST /person/ - create new person
  post '/person/?', :provides => :json do
    content_type :json

    # Use this code to choose which parameters to grab
    #new_params = accept_params(params, :first_name, :last_name, :email)
    #person = Person.new(new_params)
    
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

  ## PUT /person/:id/:email - change a person's email
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

    new_params = accept_params(params, :first_name, :last_name, :email)

    if Person.valid_id?(params[:id])
      if person = Person.first_or_create(:id => params[:id].to_i)
        person.attributes = person.attributes.merge(new_params)
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

  ## DELETE /person/:id - delete a specific person
  delete '/person/:id/?', :provides => :json do
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

  ## misc handlers: error, not_found, etc.
  get "*" do
    status 404
  end

  put_or_post "*" do
    status 404
  end

  delete "*" do
    status 404
  end

  not_found do
    json_status 404, "Not found"
  end

  error do
    json_status 500, env['sinatra.error'].message
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
