
### Prize
class Prize
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :company_id,  Integer, :required => true
  property :name,        String,  :required => true, :length => 100
  property :description, String,  :required => true, :length => 8192
  property :song_id,     Integer  # nil until claimed
  
  has n, :wishes
  has n, :songs, :through => :wishes
  
  belongs_to :company
end