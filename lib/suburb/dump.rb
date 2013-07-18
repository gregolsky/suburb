
require 'suburb/subtitles'

module Suburb

  class DumpError < StandardError
  end

  class SubtitlesDumper
    def initialize(subtitles, encoding_converter = nil, target_framerate = nil)
      if subtitles.nil?
        raise ArgumentError.new('Subtitles must not be nil')
      end

      @subtitles = subtitles
      @encoding_converter = encoding_converter
      @target_framerate = target_framerate
    end

    def dump(io)
      raise 'Not implemented'
    end

    protected

    def target_format
      raise 'Not implemented'
    end

    def dump_signature(signature)
      if @subtitles.format.signature_type != target_format.signature_type
        SignatureConverter.convert(signature, @subtitles.framerate, target_format.signature_type)
      else
        signature
      end
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

    def target_format
      SubFormat::SUBRIP
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

end



