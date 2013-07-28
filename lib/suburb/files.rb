
require 'suburb/subtitles'

module Suburb

  class FileManager

    def self.strip_extension(filename)
      File.basename(filename, ".*")
    end

    def get_dir(filepath)
      File.dirname filepath
    end

    def list_directory(directory_path)
      Dir.new(directory_path).entries
    end

  end

  class Bundle
    
    KNOWN_SUBTITLES_FILES_EXTENSIONS = [ '.txt', '.srt', '.sub' ]

    attr_reader :movie_filename, :subtitles_filename

    def initialize(movie_filename, subtitles_filename)
      @movie_filename = movie_filename
      @subtitles_filename = subtitles_filename
    end

    def basename
      FileManager.strip_extension(@movie_filename)
    end

    def self.resolve(movie_filename, file_manager)
      directory_path = file_manager.get_dir movie_filename
      dir_entries = file_manager.list_directory directory_path
      base = FileManager.strip_extension movie_filename
      subtitles_filename = dir_entries.select { |entry| FileManager.strip_extension(entry) == base and KNOWN_SUBTITLES_FILES_EXTENSIONS.any? { |ext| entry.end_with? ext } }.first

      if subtitles_filename.nil?
        raise SuburbError.new("Subtitles file not found.")
      end

      Bundle.new(movie_filename, subtitles_filename)
    end

  end

  class SubtitlesFilenamePolicy

    def self.resolve_name(bundle, subtitles, options)
      format = Format.by_name options[:target_format]

      if format.file_extension != subtitles.format.file_extension or options[:overwrite_original_file]
        "#{bundle.basename}.#{format.file_extension}"
      else
        "#{bundle.basename}_converted.#{format.file_extension}"
      end
    end

  end


end
