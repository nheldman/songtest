Factory.define :person do |p|
  p.first_name 'Noah'
  p.last_name 'Heldman'
  p.email 'nheldman@fairwaytech.com'
end

Factory.define :genre do |g|
  g.id 'electronica'
  g.name 'Electronica'
end

Factory.define :song do |s|
  s.person_id 1
  s.artist 'Noah Heldman'
  s.title 'The Song That Never Was (Imogen Heap Remix)'
  s.soundcloud_url 'http://soundcloud.com/noah_heldman/the-song-that-never-was-49'
  s.lyrics 'Green to this, where\'s a manual when you need one?'
  s.genre_id 'electronica'
end