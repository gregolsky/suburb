
require 'txt2srt/convert'

module Txt2Srt

  VERSION = '0.1'

  class Program

    def initialize
      @converter = Converter.new

      if ARGV.length == 0
        puts "Usage: txt2srt [movie filename]"
        exit 0
      end

      @filenames = ARGV
    end

    def run
      @filenames.each { |filename| @converter.convert filename }
    end

  end

end


