require 'yaml'

module Suburb

    class Config

      @@config_path = '~/.suburb'

      def full_path
        File.expand_path(@@config_path)
      end

      def initialize
        begin
          @cfg = YAML.load_file(self.full_path)
        rescue
          self.create
        end
      end
      
      protected
      
      def get(key)
        if not @cfg
          self.create
        end
      
        begin
          @cfg['config'][key]
        rescue
          puts 'Configuration error'
          puts @cfg.inspect
          self.create
        end
      end
      
      def create
        cfg = {
          'config' => {
            'source subtitles encoding' => 'Windows-1250',
            'target subtitles encoding' => 'UTF-8',
            'target subtitles format' => 'SubRip',
            'overwrite original file' => false
          }
        }
        
        File.open(self.full_path, 'w') { |f| f.write(YAML.dump(cfg)) }
        puts 'Setup your ~/.suburb file and run again'
        exit 0
      end
      
    end
    
    class SuburbConfig < Config
    
      def source_subtitles_encoding
        self.get('source subtitles encoding')
      end
      
      def target_subtitles_format
        self.get('target subtitles format')
      end    

      def target_subtitles_encoding
        self.get('target subtitles encoding')
      end     

      def keep_src_file
        self.get('overwrite original file')
      end  

    end
    
    class CommandLineOptions
    
      def CommandLineOptions.create(config)
          require 'trollop'
          Trollop::options do
            opt :source_encoding, "Source subtitles encoding", :type => String, :default => config.source_subtitles_encoding
            opt :target_encoding, "Target subtitles encoding", :type => String, :default => config.target_subtitles_encoding
            opt :target_format, "Target subtitles format (SubRip, Micro DVD, MPL2, TMP)", :type => String, :default => config.target_subtitles_format
            opt :overwrite_original_file, "Overwrite original subtitles file, if needed", :default => config.keep_src_file
          end
      end
    end  

end

        
