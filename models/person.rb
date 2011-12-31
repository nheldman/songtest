
### Person
class Person
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :first_name,           String, :required => true
  property :last_name,            String, :required => true
  property :email,                String, :required => true, :length => 100, :format => :email_address, :unique => true
  property :password,             BCryptHash, :required => true
  
  has n, :roles, :through => Resource
  has n, :songs
  has n, :votes
  has 1, :company
  
  def in_role? (role)
    roles.any? { |r| r.name.to_sym == role }
  end
end