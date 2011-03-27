module EC2Boot
    class Actions
        include Log

        def initialize(config)
            @actions_dir = config.actions_dir

            load_actions
        end

        def load_actions
            log "load_actions"
            Dir.entries(@actions_dir).grep(/\.rb$/).each do |cmd|
                item = [@actions_dir, cmd].join("/")
                log "about to load: #{item}"
                load item
            end
        end

        def run_actions(ud, md, config)
            log "run_actions"
            if ud.user_data.is_a?(Hash)
                if ud.user_data.include?(:actions)
                    ud.user_data[:actions].each do |action|
                        if action.include?(:type)
                            type = action[:type].to_s
                            meth = "#{type}_action"

                            if respond_to?(meth)
                                begin
                                    log("Running action '#{type}'")

                                    send(meth, action, ud, md, config)
                                rescue Exception => e
                                    log("Failed to run action #{type}: #{e.class}: #{e}")
                                end
                            else
                                log "no method: #{meth}"
                                # no such method
                            end
                        else
                            log ":action '#{action}' contains no type"
                            # no type
                        end
                    end
                else
                    log "No :actions in user-data"
                    # no :actions
                end
            else
                log "user-data not a hash"
                # not a hash
            end
        end
    end
end
