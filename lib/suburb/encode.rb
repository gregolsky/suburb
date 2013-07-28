
module Suburb

  class EncodingConverter
    
    def initialize(source_encoding, target_encoding)
      
      if source_encoding.nil? or target_encoding.nil? or source_encoding == target_encoding
        @encoder = lambda { |x, src_enc, dst_enc| x }
      else
        @source_encoding, @target_encoding = source_encoding, target_encoding
        @encoder = lambda { |x, src_enc, dst_enc| x.encode!(dst_enc, src_enc) }
      end
    end    

    def change_encoding!(arg)
      @encoder.call(arg, @src_encoding, @target_encoding)
    end

  end

end
