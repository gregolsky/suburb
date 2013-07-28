
require 'rvideo'

module Suburb

  module Video

    module_function

    def get_framerate(filename)
      RVideo::Inspector.new(:file => filename).fps.to_f
    end
  end

end
