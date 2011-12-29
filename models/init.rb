### datamapper requires
require 'data_mapper'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'

## model
### helper modules
#### StandardProperties
module StandardProperties
  def self.included(other)
    other.class_eval do
      property :id, other::Serial
      property :created_at, DateTime
      property :updated_at, DateTime
    end
  end
end

#### Validations
module Validations
  def valid_id?(id)
    id && id.to_s =~ /^\d+$/
  end
  
  def valid_genre?(id)
    id && id.to_s =~ /^[A-Za-z]+$/
  end
end

# These requires must be at the bottom of the file
require_relative 'person'
require_relative 'genre'
require_relative 'song'
require_relative 'vote'
require_relative 'company'
require_relative 'prize'
require_relative 'wish'
require_relative 'winner'

