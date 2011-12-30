require 'spec_helper'

describe "SongTest Winner" do
  include Rack::Test::Methods

  before(:each) do    
    @genre = FactoryGirl.attributes_for(:genre)
    post '/genre', @genre.to_json
    
    @person = FactoryGirl.attributes_for(:person)
    post '/person', @person.to_json
    
    @song = FactoryGirl.attributes_for(:song)
    post '/song', @song.to_json
    
    @winner = FactoryGirl.attributes_for(:winner)
  end
  
  describe "GET '/winner'" do    
    it "with no winners should return 200 and empty array" do
      get '/winner'

      last_response.status.should == 200
      last_response.body.should == '[]'
    end
    
    it "with winners should return all winners" do
      Winner.create(@winner)
      
      get '/winner'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result.length.should == 1
    end
  end
  
  describe "GET '/winner' by id" do
    it "with invalid id should return 404" do
      get '/winner/1'
      
      last_response.status.should == 404    
    end
    
    it "with valid id should return 200 and correct id" do
      Winner.create(@winner)
      
      get '/winner/1'
      
      last_response.status.should == 200
      result = JSON.parse(last_response.body)
      result['id'].should == 1
    end
  end
end
