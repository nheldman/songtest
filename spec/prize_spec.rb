require 'spec_helper'

describe "SongTest Prize" do
  include Rack::Test::Methods

  before(:each) do    
    @person = FactoryGirl.attributes_for(:person)
    post '/person', @person.to_json
    
    @company = FactoryGirl.attributes_for(:company)
    post '/company', @company.to_json
    
    @prize = FactoryGirl.attributes_for(:prize)
  end
  
  describe "POST '/prize'" do    
    it "without company_id should return 400" do
      @prize[:company_id] = nil

      post '/prize', @prize.to_json

      last_response.body.should == validation_error(:company_id, 400, 'Company must not be blank')
    end

    it "without name should return 400" do
      @prize[:name] = nil

      post '/prize', @prize.to_json

      last_response.body.should == validation_error(:name, 400, 'Name must not be blank')
    end

    it "without description should return 400" do
      @prize[:description] = nil

      post '/prize', @prize.to_json

      last_response.body.should == validation_error(:description, 400, 'Description must not be blank')
    end
    
    it "with valid prize should return 201 and correct id" do      
      post '/prize', @prize.to_json
      
      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "GET '/prize'" do
    it "with empty database should return 200 and no prizes" do
      get '/prize'
      
      last_response.status.should == 200
      last_response.body.should == '[]'    
    end
    
    it "with prizes in database should return 200 and correct number of prizes" do
      post '/prize', @prize.to_json
      post '/prize', @prize.to_json
      
      get '/prize'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
    end
  end
  
  describe "GET '/prize' by id" do
    it "with invalid id should return 404" do
      get '/prize/1'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      post '/prize', @prize.to_json
      
      get '/prize/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "PUT '/prize/:id'" do
    it "with invalid id should return 404" do
      put '/prize/1', @prize.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 200 and updated record" do
      post '/prize', @prize.to_json
      
      @prize[:name] = 'new'
      put '/prize/1', @prize.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['name'].should == 'new'
    end
  end
  
  describe "DELETE '/prize' by id" do
    it "with invalid id should return 404" do
      delete '/prize/1'
      
      last_response.status.should == 404
    end
    
    it "with valid id should return 204" do
      post '/prize', @prize.to_json
      
      delete '/prize/1'
      
      last_response.status.should == 204
    end
  end
  
  describe "GET /prize/:id/wishes" do
    it "with no matching prize id should return 404" do
      get '/prize/1/wishes'
      last_response.status.should == 404
    end
    
    it "with no wishes should return 200 and empty array" do
      post '/prize', @prize.to_json
      get '/prize/1/wishes'
      last_response.status.should == 200
      last_response.body.should == '[]'
    end
    
    it "with wishes should return all wishes" do
      post '/prize', @prize.to_json
      @wish = FactoryGirl.attributes_for(:wish)
      post '/wish', @wish.to_json
      
      get '/prize/1/wishes'
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 1
    end
  end
  
  describe "GET /prize/available" do
    it "with no available prizes should return 200 and empty array" do
      get '/prize/available'
      last_response.status.should == 200
      last_response.body.should == '[]'
    end
    
    it "with available prizes should return all prizes" do
      post '/prize', @prize.to_json
      
      get '/prize/available'
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 1
    end
  end
end