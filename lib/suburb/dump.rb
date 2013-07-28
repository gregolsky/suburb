
require 'suburb/subtitles'

module Suburb

  module Dump

    class DumpError < StandardError
    end

    class SubtitlesDumper

      def initialize(subtitles)
        if subtitles.nil?
          raise ArgumentError.new('Subtitles must not be nil')
        end

        @subtitles = subtitles
      end

      def dump(io)
        raise 'Not implemented'
      end

      protected

      def self.target_format
        raise 'Not implemented'
      end

      def dump_signature(signature)
        kls = self.class
        result = signature
        if @subtitles.format.signature_type != kls.target_format.signature_type
          result = SignatureConverter.convert(signature, @subtitles.framerate, kls.target_format.signature_type)
        end
        
        result
      end

    end

    class SubRipDumper < SubtitlesDumper

      def dump(io)
        @subtitles.lines.each_with_index do |subline, i|
          io.write "#{i + 1}\r\n"
          io.write format_signatures(subline)
          subline.text_lines.each { |text_line| io.write("#{text_line}\r\n") }
          io.write("\r\n")
        end
      end

      protected

      def self.target_format
        Format::SUBRIP
      end

      private

      TIME_FORMAT = "%H:%M:%S,%L"
    
      def format_signatures(subline)
        start, stop = dump_signature(subline.start), dump_signature(subline.stop)
        "#{start} --> #{stop}\r\n"
      end

      def dump_signature(signature)
        pre_signature = super(signature)
        signature_time = TimeConverter.to_time pre_signature
        signature_time.strftime(TIME_FORMAT)
      end

    end

    def build_dumper(subtitles, options)
      dst_format = options[:target_format]

      dumper = case dst_format.upcase
        when Format::SUBRIP.name.upcase then SubRipDumper.new(subtitles)
      end
    end

    module_function :build_dumper

  end  

end



