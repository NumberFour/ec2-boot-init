newaction("mcollective") do |cmd, ud, md, config|
    if cmd.include?(:master)
        log "Will join master #{cmd[:master]}"
    else
        log ":master missing"
    end
end
