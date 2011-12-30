require 'spec_helper'

describe "SongTest Vote" do
  include Rack::Test::Methods

  before(:each) do
    # Make sure we have a valid person and genre in the db to test against    
    @person = FactoryGirl.attributes_for(:person)
    post '/person', @person.to_json
    
    @genre = FactoryGirl.attributes_for(:genre)
    post '/genre', @genre.to_json
    
    # Add a song to vote for
    @song = FactoryGirl.attributes_for(:song)
    post '/song', @song.to_json
    
    # Create the placeholder vote
    @random_id = '000000000000'
    @vote = FactoryGirl.attributes_for(:vote)
    Vote.create(@vote)
  end
  
  describe "POST '/vote/<random id>'" do    
    it "without person_id should return 400" do
      @vote[:person_id] = nil
      
      post "/vote/#{@random_id}", @vote.to_json

      last_response.body.should == validation_error(:person_id, 400, 'Person must not be blank')
    end

    it "without song_id should return 400" do
      @vote[:song_id] = nil

      post "/vote/#{@random_id}", @vote.to_json

      last_response.body.should == validation_error(:song_id, 400, 'Song must not be blank')
    end

    it "without rating should return 400" do
      @vote[:rating] = nil

      post "/vote/#{@random_id}", @vote.to_json

      last_response.body.should == validation_error(:rating, 400, 'Rating must not be blank')
    end
    
    it "without rating below 1 should return 400" do
      @vote[:rating] = 0

      post "/vote/#{@random_id}", @vote.to_json

      last_response.body.should == validation_error(:rating, 400, 'Rating must be greater than or equal to 1')
    end
    
    it "without rating above 10 should return 400" do
      @vote[:rating] = 11

      post "/vote/#{@random_id}", @vote.to_json

      last_response.body.should == validation_error(:rating, 400, 'Rating must be less than or equal to 10')
    end
    
    it "with valid vote should return 201 and correct id" do      
      @vote[:rating] = 5
      post "/vote/#{@random_id}", @vote.to_json
      
      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "GET '/vote' by id" do
    it "with invalid id should return 404" do
      get '/vote/2'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      post '/vote', @vote.to_json
      
      get '/vote/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
  
  describe "PUT '/vote/:id'" do
    it "with invalid id should return 404" do
      put '/vote/2', @vote.to_json
      
      last_response.status.should == 400
    end
    
    it "with valid id should return 200 and updated record" do
      post '/vote', @vote.to_json
      
      @vote[:rating] = 10
      put '/vote/1', @vote.to_json
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['rating'].should == 10
    end
  end
  
  describe "DELETE '/vote' by id" do
    it "with invalid id should return 404" do
      delete '/vote/2'
      
      last_response.status.should == 404
    end
    
    it "with valid id should return 204" do
      Vote.create(@vote)
      
      delete '/vote/1'
      
      last_response.status.should == 204
    end
  end
  
end