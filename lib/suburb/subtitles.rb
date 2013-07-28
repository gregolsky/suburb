
module Suburb

    class Subtitles

      attr_reader :lines, :format, :encoding, :framerate

      def initialize(lines, encoding, format, framerate = nil)
        @lines = lines
        @format = format
        @encoding = encoding
        @framerate = framerate
      end

      def apply_framerate(framerate)
        @framerate = framerate unless !@framerate.nil?
      end

      def apply_encoding(target_encoding)
        encoder = EncodingConverter.new(@encoding, target_encoding)
        @lines.each do |line|
          line.text_lines.each { |text_line| encoder.change_encoding! text_line }
        end
      end

    end

    class SignatureType
      FRAME = 1
      TIME = 2
    end

    class Format  

      private
      
      def initialize(name, signature_type, file_extension = 'txt')
        @name = name
        @signature_type = signature_type
        @file_extension = file_extension
      end

      public

      attr_reader :name, :signature_type, :file_extension
    
      MICRO_DVD = Format.new("Micro DVD", SignatureType::FRAME).freeze

      TMP = Format.new("TMP", SignatureType::TIME).freeze

      MPL2 = Format.new("MPL2", SignatureType::TIME).freeze

      SUBRIP = Format.new("SubRip", SignatureType::TIME, 'srt').freeze

      def self.list
        [ MICRO_DVD, TMP, MPL2, SUBRIP ]
      end

      def self.by_name(name)
        self.list.select { |x| x.name == name }.first
      end

    end

    class Line

      attr_reader :start, :stop, :text_lines, :font_style, :framerate

      def initialize(start_signature, end_signature, text_lines, font_style = nil)
        @start = start_signature
        @stop = end_signature
        @text_lines = text_lines
        @font_style = font_style
      end

      def apply_stop(stop)
        @stop = stop
      end

    end

end
