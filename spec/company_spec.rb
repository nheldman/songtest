require 'spec_helper'

describe "SongTest Company" do
  include Rack::Test::Methods

  before(:each) do    
    @person = FactoryGirl.attributes_for(:person)
    post '/person', @person.to_json
    
    @company = FactoryGirl.attributes_for(:company)
  end
  
  describe "POST '/company'" do    
    it "without person_id should return 400" do
      @company[:person_id] = nil

      post '/company', @company.to_json

      last_response.body.should == validation_error(:person_id, 400, 'Person must not be blank')
    end

    it "without name should return 400" do
      @company[:name] = nil

      post '/company', @company.to_json

      last_response.body.should == validation_error(:name, 400, 'Name must not be blank')
    end

    it "without url should return 400" do
      @company[:url] = nil

      post '/company', @company.to_json

      last_response.body.should == validation_error(:url, 400, 'Url must not be blank')
    end
    
    it "with invalid url should return 400" do
      @company[:url] = 'invalid_url'
      post '/company', @company.to_json
      
      last_response.body.should == validation_error(:url, 400, 'Url has an invalid format')
    end
    
    it "with valid company should return 201 and correct id" do      
      post '/company', @company.to_json
      
      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "GET '/company'" do
    it "with empty database should return 200 and no companies" do
      get '/company'
      
      last_response.status.should == 200
      last_response.body.should == '[]'    
    end
    
    it "with companies in database should return 200 and correct number of companies" do
      post '/company', @company.to_json
      post '/company', @company.to_json
      
      get '/company'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
    end
  end
  
  describe "GET '/company' by id" do
    it "with invalid id should return 404" do
      get '/company/1'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      post '/company', @company.to_json
      
      get '/company/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "PUT '/company/:id'" do
    it "with invalid id should return 404" do
      put '/company/1', @company.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 200 and updated record" do
      post '/company', @company.to_json
      
      @company[:name] = 'new'
      put '/company/1', @company.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['name'].should == 'new'
    end
  end
  
  describe "DELETE '/company' by id" do
    it "with invalid id should return 404" do
      delete '/company/1'
      
      last_response.status.should == 404
    end
    
    it "with valid id should return 204" do
      post '/company', @company.to_json
      
      delete '/company/1'
      
      last_response.status.should == 204
    end
  end
  
  describe "GET /company/:id/prizes" do
    it "with no matching company id should return 404" do
      get '/company/1/prizes'
      last_response.status.should == 404
    end
    
    it "with no prizes should return 200 and empty array" do
      post '/company', @company.to_json
      get '/company/1/prizes'
      last_response.status.should == 200
      last_response.body.should == '[]'
    end
    
    it "with prizes should return all prizes" do
      post '/company', @company.to_json
      @prize = FactoryGirl.attributes_for(:prize)
      post '/prize', @prize.to_json
      
      get '/company/1/prizes'
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 1
    end
  end
end