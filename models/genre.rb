
### Genre
class Genre
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :code, String, :required => true, :unique => true
  property :name, String, :required => true
end