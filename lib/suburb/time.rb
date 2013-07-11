
require 'time'

module Suburb

  class TimeConverter

    def self.convert_to_milliseconds(seconds, minutes = 0, hours = 0)
      seconds_in_minutes = 60 * minutes
      seconds_in_hours = 3600 * hours
      (seconds + seconds_in_minutes + seconds_in_hours) * 1000
    end

  end

end
