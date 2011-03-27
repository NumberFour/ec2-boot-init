module EC2Boot
    class LocalConfig
        attr_reader :user_data_url, :meta_data_url, :cache_dir, :actions_dir, :actions, :facts_file, :motd_file, :motd_template

        def initialize
            tmpdir = "#{ENV['HOME']}/tmp"
            confighost = "127.0.0.1"

            @user_data_url = "http://#{confighost}/latest/user-data"
            @meta_data_url = "http://#{confighost}/latest/meta-data/"
            @cache_dir = "#{tmpdir}/var/spool/ec2boot"
            @actions_dir = "#{ENV['PWD']}/actions"
            @facts_file = "#{tmpdir}/etc/facts.txt"
            @motd_file = "#{tmpdir}/etc/motd"
            @motd_template = "#{ENV['PWD']}/motd.provisioned"
            
            @actions = Actions.new(self)
        
            FileUtils.mkdir_p("#{tmpdir}/etc")
            FileUtils.mkdir_p(@cache_dir)
            FileUtils.mkdir_p(@actions_dir)
        end
    end
end
