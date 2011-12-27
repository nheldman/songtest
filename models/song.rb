
### Song
class Song
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :person_id,      Integer, :required => true
  property :artist,         String,  :required => true, :length => 100
  property :title,          String,  :required => true, :length => 100
  property :soundcloud_url, String,  :required => true, :length => 1024
  property :lyrics,         String,                     :length => 1024
  property :genre_id,       String,  :required => true, :length => 16
  
  belongs_to :person
  belongs_to :genre
end