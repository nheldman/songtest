require 'spec_helper'

describe "SongTest Genre" do
  include Rack::Test::Methods

  before(:each) do    
    @genre = FactoryGirl.attributes_for(:genre)
  end
  
  describe "POST '/genre'" do  
    it "without code should return 400" do
      @genre[:code] = nil

      post '/genre', @genre.to_json

      last_response.body.should == validation_error(:code, 400, 'Code must not be blank')
    end
    
    it "with duplicate code should return 400" do
      post '/genre', @genre.to_json
      post '/genre', @genre.to_json
      
      last_response.status.should == 400
    end

    it "without name should return 400" do
      @genre[:name] = nil

      post '/genre', @genre.to_json

      last_response.body.should == validation_error(:name, 400, 'Name must not be blank')
    end

    it "with valid genre should return 201 and correct id" do      
      post '/genre', @genre.to_json
      
      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "GET '/genre'" do
    it "with empty database should return 200 and no genres" do
      get '/genre'
      
      last_response.status.should == 200
      last_response.body.should == '[]'    
    end
    
    it "with genres in database should return 200 and correct number of genres" do
      post '/genre', @genre.to_json
      @genre[:code] = 'new'
      post '/genre', @genre.to_json
      
      get '/genre'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
    end
  end
  
  describe "GET '/genre' by id" do
    it "with invalid id should return 404" do
      get '/genre/1000'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      post '/genre', @genre.to_json
      
      get '/genre/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "PUT '/genre/:id'" do
    it "with invalid id should return 404" do
      put '/genre/1', @genre.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 200 and updated record" do
      post '/genre', @genre.to_json
      
      @genre[:name] = 'new'
      put '/genre/1', @genre.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['name'].should == 'new'
    end
  end
  
  describe "DELETE '/genre' by id" do
    it "with invalid id should return 404" do
      delete '/genre/1'
      
      last_response.status.should == 404
    end
    
    it "with valid id should return 204" do
      post '/genre', @genre.to_json
      
      delete '/genre/1'
      
      last_response.status.should == 204
    end
  end
end