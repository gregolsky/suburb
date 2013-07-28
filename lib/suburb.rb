
require 'suburb/commands'
require 'suburb/config'
require 'suburb/errors'

module Suburb

  class Program

    def initialize

      cfg = SuburbConfig.new
      @options = CommandLineOptions.create(cfg)

      if ARGV.length == 0
        puts "Movie filename missing."
        exit 0
      end

      @filenames = ARGV
    end

    def run
      ConvertFilesCommand.new(@filenames, @options).execute
    rescue SuburbError => error
      puts error.message
    end

  end

end


