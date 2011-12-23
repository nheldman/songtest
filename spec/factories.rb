Factory.define :person do |p|
  p.first_name 'Noah'
  p.last_name 'Heldman'
  p.email 'nheldman@fairwaytech.com'
end

Factory.define :genre do |g|
  g.code 'pop'
  g.name 'Pop'
end