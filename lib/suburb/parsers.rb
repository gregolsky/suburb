
require 'suburb/subtitles'
require 'suburb/time'

module Suburb

  class SubParsingError < StandardError
  end

  class SubtitlesParser

    def initialize(io, filename, encoding)
      @io = io
      @filename = filename
      @encoding = encoding
    end

    protected

    def build_subtitles(lines)
      Subtitles.new(lines, @encoding, get_format)
    end
    
  end

  class SubtitleLinePerLineFileParser < SubtitlesParser
    
    def initialize(io, filename, encoding)
      super(io, filename, encoding)
    end

    def parse
      lines = @io.readlines.map { |line| transform_line_to_subline(line) }
      build_subtitles(lines)
    end

    protected

    def transform_line_to_subline(line)
      raise 'Not implemented'
    end

    def get_format
      raise 'Not implemented'
    end

  end

  class MicroDvdParser < SubtitleLinePerLineFileParser

    def initialize(io, filename, encoding)
      super(io, filename, encoding)
    end

    def transform_line_to_subline(line)
      m = line.match(/^{(\d+)}{(\d+)}(.*)$/)

      if m.nil? or m.length != 4
        raise SubParsingError.new("Invalid subtitles format: #{line}")
      end 
      
      start_signature, end_signature, text = m[1].to_i, m[2].to_i, m[3].strip.split('|')
      SubLine.new(start_signature, end_signature, text)
    end

    def get_format
      SubFormat::MICRO_DVD
    end

  end

  class TMPParser < SubtitleLinePerLineFileParser

    def initialize(io, filename, encoding)
      super(io, filename, encoding)
    end

    def transform_line_to_subline(line)
      m = line.match(/^(\d+):(\d+):(\d+)[ :](.*)$/)

      if m.nil? or m.length != 5
        raise SubParsingError.new("Invalid subtitles format: #{line}")
      end 
      
      hour, minute, seconds, text = m[1].to_i, m[2].to_i, m[3].to_i, m[3].strip.split('|')
      milliseconds = Suburb::TimeConverter.convert_to_milliseconds(seconds, minute, hour)
      SubLine.new(milliseconds, nil, text)
    end

    def get_format
      SubFormat::TMP
    end

  end

  class Mpl2Parser < SubtitleLinePerLineFileParser

    def initialize(io, filename, encoding)
      super(io, filename, encoding)
    end

    def transform_line_to_subline(line)
      m = line.match(/^\[(\d+)\]\[(\d+)\](.*)$/)

      if m.nil? or m.length != 4
        raise SubParsingError.new("Invalid subtitles format: #{line}")
      end 
      
      start_signature, end_signature, text = m[1].to_i, m[2].to_i, m[3].strip.split('|')
      SubLine.new(start_signature * 100, end_signature * 100, text)
    end

    def get_format
      SubFormat::MPL2
    end

  end

  class SubRipParser < SubtitlesParser

    def initialize(io, filename, encoding)
      super(io, filename, encoding)
      reset_current_subline
    end

    def parse
      lines = []

      @io.readlines
        .map { |l| l.strip }
        .each do |line|
        
          if line.empty?
            lines << SubLine.new(@signatures[0], @signatures[1], @text_lines)
            reset_current_subline
            next
          end

          if @counter.nil?
            parse_counter line
            next if not @counter.nil?
          end

          if @signatures.nil?
            @signatures = parse_signatures line
            next
          end
        
          @text_lines << line

      end

      build_subtitles(lines)
    end

    def reset_current_subline
      @counter = nil
      @signatures = nil
      @text_lines = []
    end

    def build_subline
      SubLine.new(@signatures[0], @signatures[1], @text_lines)
    end

    def parse_counter(line)
      m = line.match(/^(\d+).*$/)
      @counter = m[1].to_i unless (m.nil? or m[1].to_i == 0)
    end

    def parse_signatures(line)
      m = line.match(/^(\d+):(\d+):(\d+),(\d+)\s+-->\s+(\d+):(\d+):(\d+),(\d+)$/)

      if m.nil? or m.length != 9
        raise SubParsingError.new("Invalid subtitles format: #{line}")
      end 

      sigStartHour, sigStartMin, sigStartSec, sigStartMilli = m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i
      sigEndHour, sigEndMin, sigEndSec, sigEndMilli = m[5].to_i, m[6].to_i, m[7].to_i, m[8].to_i
      sigStart = Suburb::TimeConverter.convert_to_milliseconds(sigStartSec, sigStartMin, sigStartHour) + sigStartMilli
      sigEnd = Suburb::TimeConverter.convert_to_milliseconds(sigEndSec, sigEndMin, sigEndHour) + sigEndMilli
      [ sigStart, sigEnd ]
    end

    def get_format
      SubFormat::SUBRIP
    end

  end

end

















