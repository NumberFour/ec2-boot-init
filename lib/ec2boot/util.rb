module EC2Boot
    class Util
        include Log

        # Fetches a url, it will retry 5 times if it still
        # failed it will return ""
        #
        # If an optional file is specified it will write
        # the retrieved data into the file in an efficient way
        # in this case return data will be true or false
        #
        # raises URLNotFound for 404s and URLFetchFailed for
        # other non 200 status codes
        def self.get_url(url, file=nil)
            log("get_url(#{url}, #{file})")

            uri = URI.parse(url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = (uri.scheme == 'https')
            retries = 5

            #log "parsed to: #{uri}"
            begin
                if file
                    dest_file = File.open(file, "w")
                    response = http.get(uri.path) do |r|
                        dest_file.write r
                    end
                    dest_file.close
                else
                    response = http.get(uri.path)
                end

                raise URLNotFound if response.code == "404"
                raise URLFetchFailed, "#{url}: #{response.code}" unless response.code == "200"

                if response.code == "200"
                    if file
                        return true
                    else
                        return response.body
                    end
                else
                    if file
                        return false
                    else
                        return ""
                    end
                end
            rescue Timeout::Error => e
                retries -= 1
                sleep 1
                retry if retries > 0

            rescue URLFetchFailed => e
                retries -= 1
                sleep 1
                retry if retries > 0
            end
        end

        # updates the motd, updates all @@foo@@ variables
        # with data from the facts
        def self.update_motd(ud, md, config)
            templ = File.readlines(config.motd_template)

            File.open(config.motd_file, "w") do |motd|
                templ.each do |line|
                    if md.fetched?
                        [ "ami_id", "instance_type" , "placement_availability_zone", "instance_id" ].each do |key|
                            line.gsub!(/@@#{key}@@/, md.flat_data["#{key}"]) if md.flat_data.has_key?("#{key}")
                        end
                    end

                    motd.write line
                end
            end
        end

        public
        def self.copy_file_to_tmp(source)
            require 'tempfile'
            require 'ftools'


            tmpfile=Tempfile.new("ruby")
            File.copy(source,tmpfile.path) if File.file? source
            return tmpfile.path
        end

        public
        def self.copy_file(source,target)
            require 'ftools'

            File.copy(source,target)
        end

        private
        def self.update_facts_from_file(file,ud, md, config)
            File.open(file, "w") do |facts|
                if ud.fetched?
                    log "update user data"
                    data = ud.flat_data
                    if data.is_a?(Hash)
                        if data.include?(:facts)
                            data[:facts].each_pair do |k,v|
                                facts.puts("#{k}=#{v}")
                            end
                        else
                            log("user-data does not include :facts")
                        end
                    else
                        log("user-data not a hash")
                    end
                end

                if md.fetched?
                    log "update metadata"
                    data = md.flat_data

                    data.keys.sort.each do |k|
                        facts.puts("# ec2_#{k}=#{data[k]}")
                    end
                else
                    log "data not fetched"
                end

                if data.include?("placement_availability_zone")
                    log "update region data"
                    facts.puts("# ec2_placement_region=" + data["placement_availability_zone"].chop)
                end
            end
        end

        # writes out the facts file
        public
        def self.write_facts(ud, md, config)
            log "Copy facts to tmp file"
            tmpfile=Util.copy_file_to_tmp(config.facts_file)
            log "Load data from tmp file: #{tmpfile}"
            Util.update_facts_from_file(tmpfile, ud, md, config)
            log "Publishes new #{config.facts_file} using content from #{tmpfile}"
            Util.copy_file(tmpfile,config.facts_file)
            log "Deletes #{tmpfile}"
            File.delete(tmpfile)
            log "Done."
        end
    end
end
