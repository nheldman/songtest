
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
  property :vote_count,     Integer, :required => true, :default => 0
  
  has n, :votes
  has n, :wishes
  has n, :prizes, :through => :wishes
  
  belongs_to :person
  belongs_to :genre
  
  def self.random_id
    chars =  [('a'..'z'),(0..9)].map{|i| i.to_a}.flatten;  
    random_id = (0..11).map{ chars[rand(chars.length)] }.join;
  end
  
  def self.no_votes_by_person_id_and_fewest_total_votes(person_id)
    # Get a song from the database that has not yet been voted for by this person,
    # and has the fewest total votes
    
    # TODO: Restrict this to only return results for the current contest (current month?)
    
    # First, see if there are any songs with no votes.  If so, grab the first one.
    if first_song_with_no_votes = Song.first(:votes => nil, :order => [ :created_at.asc ])
      first_song_with_no_votes
    else
      songs_by_fewest_votes = Song.all(Song.votes.person_id.not => person_id, :order => [ :vote_count.asc ])
      songs_by_current_user = Song.all(:person_id => person_id)
      
      matching_songs = songs_by_fewest_votes - songs_by_current_user
      matching_songs.first
    end
  end
end