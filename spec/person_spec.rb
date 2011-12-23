require 'spec_helper'

describe "SongTest Person" do
  include Rack::Test::Methods

  before(:each) do    
    header 'Content-Type', 'application/json'
    header 'Accept', 'application/json'
  end
  
  describe "POST '/person'" do  
    before(:each) do
      @person = FactoryGirl.attributes_for(:person)
    end
    
    it "without first_name should return 400" do
      @person[:first_name] = nil

      post '/person', @person.to_json

      last_response.body.should == validation_error(:first_name, 400, 'First name must not be blank')
    end

    it "without last_name should return 400" do
      @person[:last_name] = nil

      post '/person', @person.to_json

      last_response.body.should == validation_error(:last_name, 400, 'Last name must not be blank')
    end

    it "without email should return 400" do
      @person[:email] = nil

      post '/person', @person.to_json

      last_response.body.should == validation_error(:email, 400, 'Email must not be blank')
    end

    it "valid person should return 201 and correct id" do      
      post '/person', @person.to_json
      
      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "GET '/person'" do
    it "with empty database should return 200 and no people" do
      get '/person'
      
      last_response.status.should == 200
      last_response.body.should == '[]'    
    end
    
    it "with people in database should return 200 and correct number of people" do
      person = FactoryGirl.attributes_for(:person)
      post '/person', person.to_json
      post '/person', person.to_json
      
      get '/person'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
    end
  end
  
  describe "GET '/person' by id" do
    it "with invalid id should return 404" do
      get '/person/1000'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      person = FactoryGirl.attributes_for(:person)
      post '/person', person.to_json
      
      get '/person/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
end