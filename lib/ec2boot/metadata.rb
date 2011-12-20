require 'pp'

module EC2Boot
    class MetaData<Data
        include Log

        attr_reader :meta_data

        def initialize(config, metadata=nil)
            @meta_data = nil
            @flat_data_cache = nil

            super(config)

            FileUtils.mkdir_p(@config.cache_dir + "/meta-data")

            if !metadata
                log "Will fetch metadata"
                fetch
            else
                log "Override metadata with supplied: #{PP.pp(metadata, dump="")}"
                @meta_data = metadata
                @fetched = true
            end
        end

        def flat_data
            @flat_data_cache = flatten(@meta_data) if ! @flat_data_cache
            @flat_data_cache
        end

        private
        def fetch
            @meta_data = get_tree("/")
            @fetched = true
        end

        # gets an entire tree of ec2 data
        def get_tree(root)
            tree_url = @config.meta_data_url + root
            cache_root = @config.cache_dir + "/meta-data/" + root

            keys = {}

            tree_root = Util.get_url(tree_url).split("\n")

            tree_root.each do |branch|
                if branch =~ /\/$/
                    # its a sub dir
                    keyname = branch.chop

                    FileUtils.mkdir_p(cache_root + "/" + branch)
                    keys[keyname] = get_tree(root + "/" + branch)
                else
                    if branch =~ /(.+?)=(.+)/
                        FileUtils.mkdir_p(cache_root + "/" + $1)
                        keys[$1] = get_tree(root + "/" + $1 + "/")
                    else
                        keys[branch] = get_key(root + "/" + branch)
                    end
                end
            end

            keys
        end

        # strip out all //'s in key paths
        def clean_path(path)
            path = path.gsub(/\/\//, "/")

            if path.match(/\/\//)
                path = clean_path if path.match(/\/\//)
            end

            path
        end

        # gets a key, looks in the cache first
        def get_key(key)
            url = @config.meta_data_url + clean_path(key)
            cache_file = clean_path(@config.cache_dir + "/meta-data" + key)

            if File.exist?(cache_file)
                val = File.read(cache_file)
            else
                val = Util.get_url(url).chomp
                File.open(cache_file, "w") {|f| f.print val}
            end

            val
        end
    end
end
