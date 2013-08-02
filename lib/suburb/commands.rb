
require 'suburb/files'
require 'suburb/video'
require 'suburb/encode'
require 'suburb/parse'
require 'suburb/dump'
require 'stringio'

module Suburb

  class ConvertFilesCommand

    def initialize(video_files, options)
      @video_files = video_files
      @options = options
      @file_manager = FileManager.new
    end

    def execute
      @video_files.each do |video_file|
        bundle = resolve_bundle video_file
        subtitles = load_subtitles bundle
        dump_result(bundle, subtitles)
      end
    end
  
    def load_subtitles(bundle)
      source_encoding = @options[:source_encoding]
      File.open(bundle.subtitles_filename, "r:#{source_encoding}:UTF-8") do |io|
        subtitles = Parse::SubtitlesLoader.load(io, bundle.subtitles_filename, source_encoding)
        framerate = Video.get_framerate bundle.movie_filename
        subtitles.apply_framerate framerate
        subtitles
      end      
    end

    def resolve_bundle(video_file)
      bundle = Bundle.resolve(video_file, @file_manager)
    end

    def dump_result(bundle, subtitles)
      dumper = Dump.build_dumper(subtitles, @options)
      result_filename = SubtitlesFilenamePolicy.resolve_name(bundle, subtitles, @options)
      target_encoding = @options[:target_encoding]
      File.open(result_filename, "w:#{target_encoding}") { |io| dumper.dump io }
    end

  end

end

