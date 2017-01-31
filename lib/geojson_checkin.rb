class GeojsonCheckin
  def initialize(checkin_record)
    @type = 'Feature'
    @geometry = { 'type': 'Point', 'coordinates': [checkin_record[0], checkin_record[1]] }
    @properties = { 'id': checkin_record[2] }
  end
end
