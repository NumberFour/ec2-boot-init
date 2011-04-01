module EC2Boot
    class UserData<Data
        include Log

        attr_reader :user_data, :user_data_raw

        def initialize(config)
            @user_data = nil
            @flat_data_cache = nil

            super(config)
            fetch
        end

        def flat_data
            if !@flat_data_cache
                @flat_data_cache = {}
                @flat_data_cache[:facts] = flatten(@user_data[:facts]) if @user_data.has_key?(:facts)

                log "Flattened user_data: #{PP.pp(@flat_data_cache, dump="")}"
            end
            @flat_data_cache
        end

        private
        def fetch
            log("Fetching user_data")

            if ENV['EC2BOOTINIT_LOCAL'] != ""
                log("Using LOCAL information")
                @user_data_raw = File.open(@config.cache_dir + "/user-data.raw", "r")
            else
                @user_data_raw = Util.get_url(@config.user_data_url)
            end
            @user_data = YAML.load(@user_data_raw)

            File.open(@config.cache_dir + "/user-data.raw", "w") do |ud|
                ud.puts @user_data_raw
            end

            @fetched = true
        rescue URLNotFound
            @user_data_raw = ""
            @user_data = []
        end
    end
end
