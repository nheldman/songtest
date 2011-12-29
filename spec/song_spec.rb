require 'spec_helper'

describe "SongTest Song" do
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
  
  describe "Find votable song" do
    it "should not have any votes" do
      # Add two songs
      post '/song', @song.to_json
      post '/song', @song.to_json
      
      # Vote for one of them as the current user
      person_id = 1
      
      # TODO: Use the API instead, or is this better because it is more like a mock?
      # Don't provide a rating here, we're just getting a vote placeholder
      vote = Vote.create(:person_id => person_id, :song_id => 1, :random_id => '1234567890ab')
      
      song = Song.no_votes_by_person_id_and_fewest_total_votes(person_id)
      
      song[:id].should == 2
    end
    
    it "should have the fewest votes" do
      # Add two songs
      post '/song', @song.to_json
      post '/song', @song.to_json
      
      # Vote for the first one twice, and the second one once
      Vote.create(:person_id => 2, :song_id => 1, :random_id => '1234567890ab')
      Vote.create(:person_id => 3, :song_id => 1, :random_id => '1234567890ac')
      Vote.create(:person_id => 4, :song_id => 2, :random_id => '1234567890ad')
      
      song = Song.no_votes_by_person_id_and_fewest_total_votes(1) # 1 == person_id of current user
      
      song[:id].should == 2
    end
  end
  
  describe "Random id" do
    it "should be 12 alphanumeric characters" do
      random_id = Song.random_id
      
      random_id.should =~ /^[a-z0-9]{12}$/ 
    end
  end
  
  describe "POST '/song/random'" do
    it "should redirect to a one-time random id" do
      # make sure we have a song in the database
      post '/song', @song.to_json
      
      post '/song/random'
      
      follow_redirect!
      
      last_request.url.should =~ /\/song\/[a-z0-9]{12}$/
    end
    
    it "should add a song_vote for the current user and song" do
      # make sure we have a song in the database
      post '/song', @song.to_json
      
      post '/song/random'
      follow_redirect!
      
      random_id = last_request.url[-12,12]
      vote = Vote.first(:random_id => random_id)
      
      vote['song_id'].should == 1
      # TODO: Validate that the person_id in song_vote is correct
      vote['person_id'].should == 1
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