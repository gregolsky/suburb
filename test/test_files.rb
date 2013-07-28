
require 'suburb/files'
require 'test/unit'

class FileManagementTests < Test::Unit::TestCase

  def setup
    dir_list = [ "test.mkv", "test.txt", "test2.exe.zip", "atest3", "test.srt" ]
    fake_list_dir = lambda { |x| dir_list }
    @mocked_file_manager = Mock.new({ 
        :list_directory => fake_list_dir, 
        :strip_extension => lambda { |n| File.basename(n, ".*") },
        :get_dir => lambda { |n| File.dirname(n) }
      })
  end

  def test_resolving_of_bundle  
    bundle = Suburb::Bundle.resolve("test.mkv", @mocked_file_manager)
    assert_not_nil bundle
    assert_equal 'test.mkv', bundle.movie_filename
    assert_equal 'test.txt', bundle.subtitles_filename
  end

  def test_should_resolve_name_for_non_conflicting_subtitles_format
    test_bundle = Suburb::Bundle.new("test.mkv", "test.txt")
    test_subs = Suburb::Subtitles.new(nil, nil, Suburb::Format::MICRO_DVD)
    options = { :overwrite_original_file => false, :target_format => "SubRip" }
    result = Suburb::SubtitlesFilenamePolicy.resolve_name(test_bundle, test_subs, options)
    assert_equal("test.srt", result)
  end

  def test_should_resolve_name_for_conflicting_subtitles_format
    test_bundle = Suburb::Bundle.new("test.mkv", "test.txt")
    test_subs = Suburb::Subtitles.new(nil, nil, Suburb::Format::MICRO_DVD)
    options = { :overwrite_original_file => false, :target_format => "MPL2" }
    result = Suburb::SubtitlesFilenamePolicy.resolve_name(test_bundle, test_subs, options)
    assert_equal("test_converted.txt", result)
  end

  def test_should_resolve_name_for_conflicting_subtitles_format_and_when_overwrite_source_is_turned_on
    test_bundle = Suburb::Bundle.new("test.mkv", "test.txt")
    test_subs = Suburb::Subtitles.new(nil, nil, Suburb::Format::MICRO_DVD)
    options = { :overwrite_original_file => true, :target_format => "MPL2" }
    result = Suburb::SubtitlesFilenamePolicy.resolve_name(test_bundle, test_subs, options)
    assert_equal("test.txt", result)
  end

  class Mock
    
    def initialize(properties)
      @properties = properties
    end
    
    def method_missing(name, *args, &block)
        if args.nil? or args.length == 0
          @properties[name.intern].call
        else
          @properties[name.intern].call(*args)
        end
      rescue NoMethodError => name
        raise "#{name} not registered in mock"
      
    end
    
  end

end
