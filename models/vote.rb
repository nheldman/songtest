
### Vote
class Vote
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :person_id,      Integer, :required => true
  property :song_id,        Integer, :required => true
  property :random_id,      String,  :required => true, :length => 12
  property :rating,         Integer  # not required (vote placeholder is created when they get a random song)
                                     # if they actually vote, a rating will be saved here
  property :comment,        String,  :length => 1024
  
  belongs_to :person
  belongs_to :song
  
  after :save do
    song = Song.get(self.song_id)
    song[:vote_count] += 1
    song.save
  end
  
end