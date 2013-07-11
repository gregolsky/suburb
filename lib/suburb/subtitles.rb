
module Suburb

  class Subtitles

    attr_reader :lines, :format, :encoding

    def initialize(lines, encoding, format)
      @lines = lines
      @format = format
      @encoding = encoding
    end

  end

  class SignatureType
    FRAME = 1
    TIME = 2
  end

  class SubFormat  

    private
    
    def initialize(name, signature_type)
      @name = name
      @signature_type = signature_type
    end

    public
  
    MICRO_DVD = SubFormat.new("Micro DVD", SignatureType::FRAME).freeze

    TMP = SubFormat.new("TMP", SignatureType::TIME).freeze

    MPL2 = SubFormat.new("MPL2", SignatureType::TIME).freeze

    SUBRIP = SubFormat.new("SubRip", SignatureType::TIME).freeze

  end

  class SubLine

    attr_reader :start, :end, :text_lines, :font_style

    def initialize(start_signature, end_signature, text_lines, font_style = nil)
      @start = start_signature
      @end = end_signature
      @text_lines = text_lines
      @font_style = font_style
    end

  end

end
