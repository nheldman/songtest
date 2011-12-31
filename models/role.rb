
### Role
class Role
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name,         String, :required => true
  property :description,  String
  
  has n, :people, :through => Resource
end