
### Genre
class Genre
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :code, String, :required => true
  property :name, String, :required => true
end