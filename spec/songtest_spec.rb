require 'spec_helper'

describe "SongTest Home" do
  include Rack::Test::Methods
  
  describe "GET '/'" do
    it "should return 200 OK" do
      get '/'
      last_response.status.should == 200
    end

    it "should contain 'SongTest'" do
      get '/'
      last_response.body.should == 'SongTest'
    end
  end
end