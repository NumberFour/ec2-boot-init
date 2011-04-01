#!/usr/bin/ruby

require 'ec2boot'
localmode=false

def log(msg)
    puts "#{Time.now}> #{msg}"
    system("logger", "#{msg}")
end

puts "Network mode enabled"
config = EC2Boot::Config.new

ud = EC2Boot::UserData.new(config)
md = EC2Boot::MetaData.new(config)

EC2Boot::Util.write_facts(ud, md, config)
log "Facts written."

config.actions.run_actions(ud, md, config)
log "Action run."

EC2Boot::Util.update_motd(ud, md, config)  if ud.fetched? && md.fetched?
log "Motd updated."
