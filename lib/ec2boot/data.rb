module EC2Boot
    class Data
        def initialize(config)
            @fetched = false
            @config = config
        end

        def fetched?
            @fetched
        end

        # Turns the multi dimensional ec2 data into a boring flat version
        def flatten(data, prefix = "")
            flat = {}

            #log("Will flatten #{PP.pp(data, dump="")} with prefix '#{prefix}'")
            data.each_pair do |k,v|
                key = prefix + k.to_s.gsub("-", "_")
                #log("Key is '#{key}'")

                if v.is_a?(String)
                    #log("Value '#{v}' is string")
                    v.chomp!

                    # if it's got multiple lines split them out in _x
                    if v.match("\n")
                        v.split("\n").each_with_index do |val, idx|
                            flat[key + "_#{idx}"] = val
                        end
                    else
                        flat[key] = v
                    end
                elsif v.is_a?(TrueClass) || v.is_a?(FalseClass)
                        flat[key] = v.to_s
                elsif v.is_a?(Hash)
                    #log "Flatten key '#{key}' with hash"
                    flat.merge!(flatten(v, "#{key}_"))
                end
            end

            #log("Flatten result #{PP.pp(flat, dump="")}")
            flat
        end

    end
end
