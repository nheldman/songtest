require 'spec_helper'

describe "SongTest Person" do
  include Rack::Test::Methods

  before(:each) do    
    @person = FactoryGirl.attributes_for(:person)
  end
  
  describe "POST '/person'" do    
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
    
    it "with invalid email should return 400" do
      @person[:email] = 'invalid_email'
      post '/person', @person.to_json
      
      last_response.body.should == validation_error(:email, 400, 'Email is already taken')
    end
    
    it "with duplicate email should return 400" do
      post '/person', @person.to_json
      post '/person', @person.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid person should return 201 and correct id" do      
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
      post '/person', @person.to_json
      @person[:email] = 'new_email@example.com'
      post '/person', @person.to_json
      
      get '/person'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
      # Second record should have the updated email address
      result[1]['email'].should == 'new_email@example.com'
    end
  end
  
  describe "GET '/person' by id" do
    it "with invalid id should return 404" do
      get '/person/1'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      post '/person', @person.to_json
      
      get '/person/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "PUT '/person/:id'" do
    it "with invalid id should return 404" do
      put '/person/1', @person.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 200 and updated record" do
      post '/person', @person.to_json
      
      @person[:first_name] = 'new'
      put '/person/1', @person.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['first_name'].should == 'new'
    end
  end
  
  describe "PUT '/person/:id/email/:email" do
    it "with invalid email should return 400" do
      post '/person', @person.to_json
      put '/person/1/email/invalid_email'
      
      last_response.status.should == 400
    end
          
    it "with valid email should return 200 and new email" do
      post '/person', @person.to_json
      put '/person/1/email/valid_email@example.com'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['email'].should == 'valid_email@example.com'
    end
  end
  
  describe "DELETE '/person' by id" do
    it "with invalid id should return 404" do
      delete '/person/1'
      
      last_response.status.should == 404
    end
    
    it "with valid id should return 204" do
      post '/person', @person.to_json
      
      delete '/person/1'
      
      last_response.status.should == 204
    end
  end
  
end