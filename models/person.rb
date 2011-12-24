
### Person
class Person
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :first_name, String, :required => true
  property :last_name, String, :required => true
  property :email, String, :required => true
  
  #def to_json(*a)
  #  {
  #    'first_name' => self.first_name,
  #    'last_name' => self.last_name,
  #    'email' => self.email
  #  }.to_json(*a)
  #end
end