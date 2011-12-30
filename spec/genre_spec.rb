require 'spec_helper'

describe "SongTest Genre" do
  include Rack::Test::Methods

  before(:each) do    
    @genre = FactoryGirl.attributes_for(:genre)
  end
  
  describe "POST '/genre'" do  
    it "without id should return 400" do
      @genre[:id] = nil

      post '/genre', @genre.to_json

      last_response.body.should == validation_error(:id, 400, 'Id must not be blank')
    end
    
    it "with duplicate id should return 400" do
      post '/genre', @genre.to_json
      post '/genre', @genre.to_json
      
      last_response.body.should == validation_error(:id, 400, 'Id is already taken')
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
      result['id'].should == 'electronica'
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
      @genre[:id] = 'new'
      post '/genre', @genre.to_json
      
      get '/genre'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
    end
  end
  
  describe "GET '/genre' by id" do
    it "with nonexistent id should return 404" do
      get '/genre/nonexistent'
      
      last_response.status.should == 404
    end
    
    it "with integer id should return 400" do
      get '/genre/1'
      
      last_response.status.should == 400    
    end
    
    it "with valid id should return 200 and correct name" do
      post '/genre', @genre.to_json
      
      get '/genre/electronica'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['name'].should == 'Electronica'
    end
  end
  
  describe "GET '/genre/:id/songs'" do
    it "with invalid genre should return 404" do
      post '/genre', @genre.to_json
            
      get '/genre/nonexistent/songs'
      
      last_response.status.should == 404
    end
    
    it "with valid genre and no songs should return 200 and empty array" do
      post '/genre', @genre.to_json

      get '/genre/electronica/songs'
      
      last_response.status.should == 200
      last_response.body.should == '[]'
    end
    
    it "with valid genre and songs should return all songs" do
      post '/genre', @genre.to_json
      
      @person = FactoryGirl.attributes_for(:person)
      post '/person', @person.to_json
      
      @song = FactoryGirl.attributes_for(:song)
      post '/song', @song.to_json
      
      get '/genre/electronica/songs'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 1
    end
  end
  
  describe "PUT '/genre/:id'" do
    it "with integer instead of string should return 400" do
      put '/genre/1', @genre.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid code should return 200 and updated record" do
      post '/genre', @genre.to_json
      
      @genre[:name] = 'new'
      put '/genre/electronica', @genre.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['name'].should == 'new'
    end
  end
  
  describe "DELETE '/genre' by id" do
    it "with integer instead of string should return 400" do
      delete '/genre/1'
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 204" do
      post '/genre', @genre.to_json
      
      delete '/genre/electronica'
      
      last_response.status.should == 204
    end
  end
end