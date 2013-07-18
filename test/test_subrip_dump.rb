
require 'test/unit'
require 'suburb'
require 'suburb/parse'
require 'suburb/dump'
require 'suburb/subtitles'
require 'stringio'

class SubRipDumperTests < Test::Unit::TestCase

  def setup
    @subrip_subs_content = "1" + "\r\n" +
                        "00:00:58,000 --> 00:01:01,100" + "\r\n" +
                        "Hello!" + "\r\n" + 
                        "\r\n" +
                        "2" + "\r\n" +
                        "00:01:01,300 --> 00:01:05,900" + "\r\n" +
                        "More!" + "\r\n" +
                        "Even more!" + "\r\n" + 
                        "\r\n" +
                        "3" + "\r\n" +
                        "00:01:08,400 --> 00:01:13,600" + "\r\n" +
                        "More!" + "\r\n" + "\r\n"
    parser = Suburb::SubRipParser.new(StringIO.new(@subrip_subs_content), 'something.txt', 'utf-8')
    @subrip_subs = parser.parse

    @mpl2_subs_content ="[580][611]Hello!\r\n" +
                        "[613][659]More!|Even more!\r\n" +
                        "[684][736]More!\r\n"

    parser = Suburb::Mpl2Parser.new(StringIO.new(@mpl2_subs_content), 'something.txt', 'utf-8')
    @mpl2_subs = parser.parse

    @microdvd_subs_content = "{0}{0}23.976" + "\r\n" +
                        "{1390}{1464}Hello!" + "\r\n" +
                        "{1470}{1580}More!|Even more!" + "\r\n" +
                        "{1640}{1765}More!" + "\r\n"
    parser = Suburb::MicroDvdParser.new(StringIO.new(@microdvd_subs_content), 'something.txt', 'utf-8')
    @microdvd_subs = parser.parse
  end

  def test_subrip_dump
    io = StringIO.new()
    dumper = Suburb::SubRipDumper.new(@subrip_subs)
    dumper.dump(io)
    io.rewind
    assert_equal(@subrip_subs_content, io.read)
  end

  def test_microdvd_to_subrip
    microdvd_synched_subrip_content = "1\r\n00:00:57,974 --> 00:01:01,060\r\nHello!\r\n\r\n2\r\n00:01:01,310 --> 00:01:05,898\r\nMore!\r\nEven more!\r\n\r\n3\r\n00:01:08,401 --> 00:01:13,614\r\nMore!\r\n\r\n"
    io = StringIO.new()
    dumper = Suburb::SubRipDumper.new(@microdvd_subs)
    dumper.dump(io)
    io.rewind
    assert_equal(microdvd_synched_subrip_content, io.read)
  end

  def test_mpl2_to_subrip
    io = StringIO.new()
    dumper = Suburb::SubRipDumper.new(@mpl2_subs)
    dumper.dump(io)
    io.rewind
    assert_equal(@subrip_subs_content, io.read)  
  end

end
