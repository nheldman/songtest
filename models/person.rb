
### Person
class Person
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :first_name, String, :required => true
  property :last_name,  String, :required => true
  property :email,      String, :required => true, :length => 100, :format => :email_address, :unique => true
  property :password,   BCryptHash, :required => true
  
  has n, :roles, :through => Resource
  has n, :songs
  has n, :votes
  has 1, :company
  
  # We are overriding to_json here so we never return the password
  def to_json(*a)
    {
      'id' => self.id,
      'first_name' => self.first_name,
      'last_name' => self.last_name,
      'email' => self.email,
      'created_at' => self.created_at,
      'updated_at' => self.updated_at
    }.to_json(*a)
  end
  
  def in_role? (role)
    roles.any? { |r| r.name.to_sym == role }
  end
  
  def is_admin?
    in_role? (:admin)
  end
  
  # Automatically add new people to the "User" role
  after :create do
    roles << Role.first_or_create(:name => 'user')
    self.save
  end
end