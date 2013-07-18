
module Suburb

  class Program

    def initialize
      @converter = Converter.new

      if ARGV.length == 0
        puts "Usage: suburb [movie filename]"
        exit 0
      end

      @filenames = ARGV
    end

    def run
      @filenames.each { |filename| @converter.convert filename }
    end

  end

end


