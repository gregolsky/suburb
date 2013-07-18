
module Suburb

  class Subtitles

    attr_reader :lines, :format, :encoding, :framerate
    attr_writer :framerate

    def initialize(lines, encoding, format, framerate = nil)
      @lines = lines
      @format = format
      @encoding = encoding
      @framerate = framerate
    end

  end

  class SignatureType
    FRAME = 1
    TIME = 2
  end

  class SubFormat  

    private
    
    def initialize(name, signature_type, file_extension = 'txt')
      @name = name
      @signature_type = signature_type
    end

    public

    attr_reader :name, :signature_type, :file_extension
  
    MICRO_DVD = SubFormat.new("Micro DVD", SignatureType::FRAME).freeze

    TMP = SubFormat.new("TMP", SignatureType::TIME).freeze

    MPL2 = SubFormat.new("MPL2", SignatureType::TIME).freeze

    SUBRIP = SubFormat.new("SubRip", SignatureType::TIME, 'srt').freeze

  end

  class SubLine

    attr_reader :start, :stop, :text_lines, :font_style, :framerate

    def initialize(start_signature, end_signature, text_lines, font_style = nil)
      @start = start_signature
      @stop = end_signature
      @text_lines = text_lines
      @font_style = font_style
    end

  end

end
