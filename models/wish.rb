
### Wish
class Wish
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :song_id,  Integer, :required => true, :key => true
  property :prize_id, Integer, :required => true, :key => true
  
  # TODO: Set up the correct association here
  belongs_to :song
  belongs_to :prize
end