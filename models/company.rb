
### Company
class Company
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :person_id, Integer, :required => true
  property :name,      String,  :required => true, :length => 100
  property :url,       String,  :required => true, :length => 1024
  
  has n, :prizes
  belongs_to :person
end