
### Person
class Person
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :email,      String, :required => true, :length => 100, :format => :email_address, :unique => true
  
  has n, :songs
  has n, :votes
  has 1, :company
end