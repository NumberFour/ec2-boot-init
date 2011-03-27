module Log
    # Logs to stdout and syslog
    def log(msg)
        puts "#{Time.now}> #{msg}"
        system("logger", "#{msg}")
    end
end
