require 'spec_helper'

describe "SongTest song" do
  include Rack::Test::Methods

  before(:each) do
    # Make sure we have a valid person and genre in the db to test against    
    @person = FactoryGirl.attributes_for(:person)
    post '/person', @person.to_json
    
    @genre = FactoryGirl.attributes_for(:genre)
    post '/genre', @genre.to_json
    
    @song = FactoryGirl.attributes_for(:song)
  end
  
  describe "POST '/song'" do    
    it "without person_id should return 400" do
      @song[:person_id] = nil

      post '/song', @song.to_json

      last_response.body.should == validation_error(:person_id, 400, 'Person must not be blank')
    end

    it "without artist should return 400" do
      @song[:artist] = nil

      post '/song', @song.to_json

      last_response.body.should == validation_error(:artist, 400, 'Artist must not be blank')
    end

    it "without title should return 400" do
      @song[:title] = nil

      post '/song', @song.to_json

      last_response.body.should == validation_error(:title, 400, 'Title must not be blank')
    end
    
    it "without soundcloud_url should return 400" do
      @song[:soundcloud_url] = nil

      post '/song', @song.to_json

      last_response.body.should == validation_error(:soundcloud_url, 400, 'Soundcloud url must not be blank')
    end
    
    it "without genre id should return 400" do
      @song[:genre_id] = nil

      post '/song', @song.to_json

      last_response.body.should == validation_error(:genre_id, 400, 'Genre must not be blank')
    end
    
    it "with valid song should return 201 and correct id" do      
      post '/song', @song.to_json
      
      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "GET '/song'" do
    it "with empty database should return 200 and no songs" do
      get '/song'
      
      last_response.status.should == 200
      last_response.body.should == '[]'    
    end
    
    it "with songs in database should return 200 and correct number of songs" do
      post '/song', @song.to_json
      post '/song', @song.to_json
      
      get '/song'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 2
    end
  end
  
  describe "GET '/song' by id" do
    it "with invalid id should return 404" do
      get '/song/1'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      post '/song', @song.to_json
      
      get '/song/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "PUT '/song/:id'" do
    it "with invalid id should return 404" do
      put '/song/1', @song.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 200 and updated record" do
      post '/song', @song.to_json
      
      @song[:artist] = 'new'
      put '/song/1', @song.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['artist'].should == 'new'
    end
  end
  
  describe "DELETE '/song' by id" do
    it "with invalid id should return 404" do
      delete '/song/1'
      
      last_response.status.should == 404
    end
    
    it "with valid id should return 204" do
      post '/song', @song.to_json
      
      delete '/song/1'
      
      last_response.status.should == 204
    end
  end
  
end