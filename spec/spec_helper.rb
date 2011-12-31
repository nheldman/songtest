require File.dirname(__FILE__) + '/../app'
require 'rack/test'
require 'factory_girl'
require 'factories'
require 'base64'

# Set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

# Establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.finalize
DataMapper.auto_upgrade!

RSpec.configure do |config|
  config.before(:each) do
    # Set default content-type and accept to json, since this is a JSON-only API
    header 'Content-Type', 'application/json'
    header 'Accept', 'application/json'

    # Set up and start datamapper transaction
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
      
    @person = FactoryGirl.attributes_for(:person)
    @person[:email] = 'noah.heldman@gmail.com'
    person = Person.create(@person)
    role = Role.create(:name => 'Administrator')
    person.roles << role
    person.save
    authorize @person[:email], @person[:password]
  end
    
  config.after(:each) do
    # Roll back datamapper transaction
    repository(:default).adapter.pop_transaction.rollback
  end
end

def app
  SongTest
end

def validation_error field, status, message
  {
    :status => status,
    :reason => {
      field => [message]
    }
  }.to_json
end

def basic_auth(username, password)
  "Basic " + Base64.encode64("#{username}:#{password}")
end