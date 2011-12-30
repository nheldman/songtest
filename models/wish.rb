
### Wish
class Wish
  include DataMapper::Resource
  extend Validations
  
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :song,  :key => true
  belongs_to :prize, :key => true
end