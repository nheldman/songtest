
### Winner
class Winner
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :song_id,  Integer, :required => true
  property :month,    String,  :required => true
  property :votes,    Integer, :required => true
  property :genre_id, Integer, :required => true
  property :average,  Float,   :required => true, :default => 0.0
  
  belongs_to :song
  belongs_to :genre
end