newaction("getactions") do |cmd, ud, md, config|
    if cmd.include?(:url)
        url = cmd[:url]

        log("Fetching action list from #{url}")

        list = EC2Boot::Util.get_url(url)

        list.split("\n").each do |command|
            log("Fetching command: #{command}")

            baseurl = url.split("/")[0...-1].join("/")
            body = EC2Boot::Util.get_url("#{baseurl}/#{command}")

            File.open(config.actions_dir + "/#{command}", "w") do |f|
                f.print body
            end
        end

        config.actions.load_actions
    end
end
