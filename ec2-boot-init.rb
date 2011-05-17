#!/usr/bin/ruby

require 'ec2boot'
require 'optparse'

def log(msg)
    puts "#{Time.now}> #{msg}"
    system("logger", "#{msg}")
end

localmode=false
bootmode=true
debug=false

OptionParser.new do |opts|
  opts.banner = "Usage: TODO --update"

  opts.on("-u", "--update", "only updates ec2 variables values") do |v|
    bootmode=false
  end

  opts.on("-l", "--local-mode", "Runs locally") do |v|
    localmode=true
  end

  opts.on("-d", "--debug", "Run in debug mode") do |v|
    debug=true
  end

end.parse!

if debug
   log "bootmode:#{bootmode}"
   log "localmode:#{localmode}"
   log "debug:#{debug}"
end

config = EC2Boot::Config.new

ud = EC2Boot::UserData.new(config)
md = EC2Boot::MetaData.new(config)

EC2Boot::Util.write_facts(ud, md, config)
log "Facts written."

if bootmode
    log "Boot mode enabled" if debug
    log "boot instance"
    config.actions.run_actions(ud, md, config)
    log "Action run."

    EC2Boot::Util.update_motd(ud, md, config)  if ud.fetched? && md.fetched?
    log "Motd updated."
end
