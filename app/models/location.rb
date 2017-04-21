class Location < ApplicationRecord
  belongs_to :user
  has_many :checkins

  reverse_geocoded_by :lat, :lng do |obj, results|
    if results.present?
      results.first.methods.each do |m|
        obj.send("#{m}=", results.first.send(m)) if column_names.include? m.to_s
      end
    else
      obj.update(address: 'Not yet geocoded')
    end
  end

end
