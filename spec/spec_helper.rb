require File.dirname(__FILE__) + '/../songtest.rb'
require 'rack/test'
require 'factory_girl'
require 'factories'

RSpec.configure do |config|
  config.before(:each) do
    repository(:default) do
      transaction = DataMapper::Transaction.new(repository)
      transaction.begin
      repository.adapter.push_transaction(transaction)
    end
  end
    
  config.after(:each) do
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