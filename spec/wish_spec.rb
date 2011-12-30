require 'spec_helper'

describe "SongTest Wish" do
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
    
    @company = FactoryGirl.attributes_for(:company)
    post '/company', @company.to_json
    
    @prize = FactoryGirl.attributes_for(:prize)
    post '/prize', @prize.to_json
    
    @wish = FactoryGirl.attributes_for(:wish)
  end

  describe "POST '/wish'" do    
    it "without song_id should return 400" do
      @wish[:song_id] = nil
      
      post '/wish', @wish.to_json

      last_response.body.should == validation_error(:song_id, 400, 'Song must not be blank')
    end
    
    it "with invalid song_id should return 404" do
      @wish[:song_id] = 2
      
      post '/wish', @wish.to_json

      last_response.status.should == 404
    end

    it "without prize_id should return 400" do
      @wish[:prize_id] = nil
      
      post '/wish', @wish.to_json

      last_response.body.should == validation_error(:prize_id, 400, 'Prize must not be blank')
    end

    it "with invalid prize_id should return 404" do
      @wish[:prize_id] = 2
      
      post '/wish', @wish.to_json

      last_response.status.should == 404
    end
    
    it "with valid prize should return 201 and correct id" do      
      post '/wish', @wish.to_json

      last_response.status.should == 201
      result = JSON.parse(last_response.body)
      result['song_id'].should == 1
    end
  end

  describe "DELETE '/wish/:song_id/prize_id' by id" do
    it "with invalid song_id should return 404" do
      post '/wish', @wish.to_json
      
      delete '/wish/2/1'

      last_response.status.should == 404
    end

    it "with invalid prize_id should return 404" do
      post '/wish', @wish.to_json

      delete '/wish/1/2'

      last_response.status.should == 404
    end
    
    it "with valid song_id and prize_id should return 204" do
      post '/wish', @wish.to_json

      delete '/wish/1/1'
      
      last_response.status.should == 204
    end
  end
end