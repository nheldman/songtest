
### Prize
class Prize
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :company_id,  Integer, :required => true
  property :name,        String,  :required => true, :length => 100
  property :description, String,  :required => true, :length => 8192
  property :song_id,     Integer
  
  belongs_to :company
end