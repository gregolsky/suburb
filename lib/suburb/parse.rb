
require 'suburb/subtitles'
require 'suburb/conversion'

module Suburb

  module Parse

    class ParsingError < StandardError
    end

    class SubtitlesParser

      def initialize(io, filename, encoding)
        @io = io
        @filename = filename
        @encoding = encoding
      end

      protected

      def postprocess(lines)
      end

      def build_subtitles(lines)
        postprocess lines
        Subtitles.new(lines, @encoding, get_format)
      end
      
    end

    class SubtitleLinePerLineFileParser < SubtitlesParser
      
      def initialize(io, filename, encoding)
        super(io, filename, encoding)
      end

      def parse
        lines = @io.readlines.each_with_index.map { |line, i| transform_line_to_subline(line, i) }
        build_subtitles(lines.compact)
      end

      protected

      def transform_line_to_subline(line, index)
        raise 'Not implemented'
      end

      def get_format
        raise 'Not implemented'
      end

    end

    class MicroDvdParser < SubtitleLinePerLineFileParser

      def initialize(io, filename, encoding)
        super(io, filename, encoding)
        @framerate = nil
      end

      def transform_line_to_subline(line, index)
        m = line.match(/^{(\d+)}{(\d+)}(.*)$/)

        if m.nil? or m.length != 4
          raise ParsingError.new("Invalid subtitles format: #{line}")
        end 
        
        start_signature, end_signature, text = m[1].to_i, m[2].to_i, m[3].strip.split('|')

        if index == 0 and not text.nil? and text.length > 0
          rate_parsed = text[0].to_f
          if rate_parsed != 0
            @framerate = rate_parsed 
            return
          end
        end

        Line.new(start_signature, end_signature, text)
      end

      def get_format
        Format::MICRO_DVD
      end

      def build_subtitles(lines)
        Subtitles.new(lines, @encoding, get_format, @framerate)
      end

    end

    class TMPParser < SubtitleLinePerLineFileParser

      MAX_SUBS_SHOW_DURATION = 5000

      def initialize(io, filename, encoding)
        super(io, filename, encoding)
      end

      def transform_line_to_subline(line, index)
        m = line.match(/^(\d+):(\d+):(\d+)[ :](.*)$/)

        if m.nil? or m.length != 5
          raise ParsingError.new("Invalid subtitles format: #{line}")
        end 
        
        hour, minute, seconds, text = m[1].to_i, m[2].to_i, m[3].to_i, m[4].strip.split('|')
        milliseconds = Suburb::TimeConverter.to_milliseconds(seconds, minute, hour)
        Line.new(milliseconds, nil, text)
      end

      def postprocess(lines)
        lines.each_with_index do |line, i|
          next_line = lines[i + 1]
          if next_line.nil? or next_line.start - line.start > MAX_SUBS_SHOW_DURATION
            line.apply_stop(line.start + MAX_SUBS_SHOW_DURATION)
          else
            line.apply_stop(next_line.start)
          end
        end
      end

      def get_format
        Format::TMP
      end

    end

    class Mpl2Parser < SubtitleLinePerLineFileParser

      def initialize(io, filename, encoding)
        super(io, filename, encoding)
      end

      def transform_line_to_subline(line, index)
        m = line.match(/^\[(\d+)\]\[(\d+)\](.*)$/)

        if m.nil? or m.length != 4
          raise ParsingError.new("Invalid subtitles format: #{line}")
        end 
        
        start_signature, end_signature, text = m[1].to_i, m[2].to_i, m[3].strip.split('|')
        Line.new(start_signature * 100, end_signature * 100, text)
      end

      def get_format
        Format::MPL2
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
              lines << Line.new(@signatures[0], @signatures[1], @text_lines)
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
        Line.new(@signatures[0], @signatures[1], @text_lines)
      end

      def parse_counter(line)
        m = line.match(/^(\d+).*$/)
        @counter = m[1].to_i unless (m.nil? or m[1].to_i == 0)
      end

      def parse_signatures(line)
        m = line.match(/^(\d+):(\d+):(\d+),(\d+)\s+-->\s+(\d+):(\d+):(\d+),(\d+)$/)

        if m.nil? or m.length != 9
          raise ParsingError.new("Invalid subtitles format: #{line}")
        end 

        sigStartHour, sigStartMin, sigStartSec, sigStartMilli = m[1, 4].map { |x| x.to_i }
        sigEndHour, sigEndMin, sigEndSec, sigEndMilli = m[5, 8].map { |x| x.to_i }
        sigStart = Suburb::TimeConverter.to_milliseconds(sigStartSec, sigStartMin, sigStartHour) + sigStartMilli
        sigEnd = Suburb::TimeConverter.to_milliseconds(sigEndSec, sigEndMin, sigEndHour) + sigEndMilli
        [ sigStart, sigEnd ]
      end

      def get_format
        Format::SUBRIP
      end

    end

    class SubtitlesLoader

        def self.load(io, filename, encoding)
          PARSERS.each do |parser_type|
            begin
              return try_parse(parser_type, io, filename, encoding)
            rescue Parse::ParsingError
              next
            end
          end

          nil
        end

        private

        PARSERS = [ Parse::SubRipParser, Parse::MicroDvdParser, Parse::Mpl2Parser, Parse::TMPParser ]

        def self.try_parse(parser_type, io, filename, encoding)
          io.rewind
          parser = parser_type.new(io, filename, encoding)
          parser.parse
        end

    end

  end

end

















