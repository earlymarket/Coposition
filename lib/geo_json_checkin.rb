class GeoJsonCheckin
  def initialize(checkin)
    @type = 'Feature'
    @geometry = { 'type': 'Point', 'coordinates': [checkin.lat, checkin.lng] }
    @properties = { 'id': checkin.id }
  end
end
