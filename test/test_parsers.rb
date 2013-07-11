
require 'test/unit'
require 'suburb'
require 'suburb/parsers'
require 'suburb/subtitles'
require 'stringio'

class ParsersTests < Test::Unit::TestCase

  def setup
  end

  def test_microdvd_parser
    test_subs_content = "{0}{25}Hello!" + "\r\n" +
                        "{30}{40}More!|Even more!"
    io = StringIO.new(test_subs_content)
    parser = Suburb::MicroDvdParser.new(io, 'something.txt', 'utf-8')
    result_subs = parser.parse
    assert result_subs.encoding == 'utf-8'
    assert result_subs.format == Suburb::SubFormat::MICRO_DVD
    assert result_subs.lines.length == 2, result_subs.lines.inspect
    subline1 = result_subs.lines[0]
    assert subline1.start == 0 and subline1.end == 25
    assert subline1.text_lines == [ 'Hello!' ]
    subline2 = result_subs.lines[1]
    assert subline2.start == 30 and subline2.end == 40
    assert subline2.text_lines == [ 'More!', 'Even more!' ]
  end

  def test_mpl2_parser
    test_subs_content = "[0][25]Hello!" + "\r\n" +
                    "[30][40]More!|Even more!"
    io = StringIO.new(test_subs_content)
    parser = Suburb::Mpl2Parser.new(io, 'something.txt', 'utf-8')
    result_subs = parser.parse
    assert result_subs.encoding == 'utf-8'
    assert result_subs.format == Suburb::SubFormat::MPL2
    assert result_subs.lines.length == 2, result_subs.lines.inspect
    subline1 = result_subs.lines[0]
    assert subline1.start == 0 and subline1.end == 2500
    subline2 = result_subs.lines[1]
    assert subline2.start == 3000 and subline2.end == 4000
    assert subline2.text_lines == [ 'More!', 'Even more!' ]
  end

  def test_tmplayer_parser
    test_subs_content = "00:00:25:Hello!" + "\r\n" +
                    "00:00:30:More!|Even more!"
    io = StringIO.new(test_subs_content)
    parser = Suburb::TMPParser.new(io, 'something.txt', 'utf-8')
    result_subs = parser.parse
    assert result_subs.encoding == 'utf-8'
    assert result_subs.format == Suburb::SubFormat::TMP
    assert result_subs.lines.length == 2, result_subs.lines.inspect
    subline1 = result_subs.lines[0]
    assert subline1.start == 25000 and subline1.end.nil?
    subline2 = result_subs.lines[1]
    assert subline2.start == 30000 and subline1.end.nil?
  end

  def test_subrip_parser
    test_subs_content = "1" + "\r\n" +
                        "00:00:00,000 --> 00:00:25,000" + "\r\n" +
                        "Hello!" + "\r\n" + "\r\n" +
                        "2" + "\r\n" +
                        "00:00:30,000 --> 00:00:40,000" + "\r\n" +
                        "More!" + "\r\n" +
                        "Even more!" + "\r\n" + "\r\n"
    io = StringIO.new(test_subs_content)
    parser = Suburb::SubRipParser.new(io, 'something.txt', 'utf-8')
    result_subs = parser.parse
    assert result_subs.encoding == 'utf-8'
    assert result_subs.format == Suburb::SubFormat::SUBRIP
    assert result_subs.lines.length == 2, result_subs.lines.inspect
    subline1 = result_subs.lines[0]
    puts subline1.inspect
    assert subline1.start == 0 and subline1.end == 25000
    subline2 = result_subs.lines[1]
    assert subline2.start == 30000 and subline1.end == 40000
    assert subline2.text_lines == [ 'More!', 'Even more!' ]
  end

end




