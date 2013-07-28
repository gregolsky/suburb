
require 'suburb/subtitles'

module Suburb

  class ConversionError < StandardError
  end

  class TimeConverter

    def self.to_milliseconds(seconds, minutes = 0, hours = 0)
      seconds_in_minutes = 60 * minutes
      seconds_in_hours = 3600 * hours
      (seconds + seconds_in_minutes + seconds_in_hours) * 1000
    end

    def self.to_time(milliseconds)
      Time.at(milliseconds / 1000.0).gmtime.round(3)
    end

  end

  class FramesConverter

    KNOWN_FRAMERATES = [ 23.976216, 25.0 ]

    def self.to_milliseconds(frame, framerate)
      self.check_framerate framerate
      (frame.to_f / self.normalize_framerate(framerate) * 1000.0).to_i
    end

    def self.to_frames(milliseconds, framerate)
      self.check_framerate framerate
      ((milliseconds / 1000.0) * self.normalize_framerate(framerate)).to_i
    end

    private

    def self.normalize_framerate(framerate)
      KNOWN_FRAMERATES.first { |x| x >= framerate }
    end

    def self.check_framerate(framerate)
      if framerate.nil?
        raise ConversionError.new("Framerate unknown. Cannot convert.")
      end
    end

  end

  class SignatureConverter
    
    def self.convert(signature, framerate, target_signature_type)
      if target_signature_type == SignatureType::TIME
        FramesConverter.to_milliseconds(signature, framerate)
      else
        FramesConverter.to_frames(signature, framerate)
      end
    end
  end

end
