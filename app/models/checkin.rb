class Checkin < ActiveRecord::Base

  belongs_to :device


  def self.find_range(from, size)
    order(:id).find(range_array(from, size))
  end

  protected

  def self.range_array(from, size)
    from = [from]
    (size - 1).times {|x| from << (from.last + 1)}
    from
  end

  def self.to_hash(string)
    string_order.zip(string.split(delimiter)).to_h
  end

  def self.delimiter
    "|"
  end

end