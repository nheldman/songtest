
### SongVote
class SongVote
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :person_id,      Integer, :required => true
  property :song_id,        Integer, :required => true
  property :random_id,      String,  :required => true, :length => 12
  property :voted,          Boolean, :required => true, :default => false
  
  belongs_to :person
  belongs_to :song
end