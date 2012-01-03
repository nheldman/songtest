
### Genre
class Genre
  include DataMapper::Resource
  extend Validations

  # :id here represents the "code" from Derek Sivers' original API design
  property :id, String, :required => true, :length => 16, :key => true, :unique => true
  property :name, String, :required => true, :length => 50
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :songs
end