require 'active_support/concern'

module HumanizeMinutes
  extend ActiveSupport::Concern

  def humanize_minutes(minutes)
    if minutes < 60
      "#{minutes} #{'minute'.pluralize(minutes)}."
    elsif minutes < 1440
      hours = minutes / 60
      minutes = minutes % 60
      "#{hours} #{'hour'.pluralize(hours)} and #{minutes} #{'minutes'.pluralize(minutes)}."
    else
      days = minutes / 1440
      "#{days} #{'day'.pluralize(days)}."
    end
  end
end
