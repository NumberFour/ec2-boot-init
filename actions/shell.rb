newaction("shell") do |cmd, ud, md, config|
    if cmd.include?(:command)
        log "Will execute '#{cmd[:command]}'."
        system(cmd[:command])
    else
        log "System-action does not include :command."
    end
end
