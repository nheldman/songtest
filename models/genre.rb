
### Genre
class Genre
  include DataMapper::Resource
  extend Validations

  property :id, String, :required => true, :length => 16, :key => true, :unique => true
  property :name, String, :required => true, :length => 50
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :songs
    #:model => 'Song',
    #:parent_key => [ :code ],
    #:child_key => [ :genre_code ]
end