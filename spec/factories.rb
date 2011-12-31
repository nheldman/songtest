Factory.define :person do |p|
  p.first_name 'Noah'
  p.last_name 'Heldman'
  p.email 'nheldman@fairwaytech.com'
  p.password 'password'
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

Factory.define :vote do |v|
  v.person_id 1
  v.song_id 1
  v.random_id '000000000000'
end

Factory.define :company do |c|
  c.person_id 1
  c.name 'Fairway Technologies'
  c.url 'http://fairwaytech.com'
end

Factory.define :prize do |p|
  p.company_id 1
  p.name 'Avalon VT-737SP Pure Class A - Direct Signal Path'
  p.description 'The Avalon VT-737SP features a combination of TUBE preamplifiers, opto-compressor, sweep equalizer, output level and VU metering in a 2U space.'
end

Factory.define :wish do |w|
  w.song_id 1
  w.prize_id 1
end

Factory.define :winner do |w|
  w.month '01/2012'
  w.genre_id 'electronica'
  w.song_id 1
  w.votes 1
  w.average 1.0
end