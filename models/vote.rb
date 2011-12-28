
### Vote
class Vote
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :person_id,      Integer, :required => true
  property :song_id,        Integer, :required => true
  property :rating,         Integer, :required => true
  property :comment,        String,  :length => 1024
  
  belongs_to :person
  belongs_to :song
end