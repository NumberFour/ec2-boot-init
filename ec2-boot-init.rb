#!/usr/bin/ruby

require 'ec2boot'
require 'optparse'

def log(msg)
    puts "#{Time.now}> #{msg}"
    system("logger", "#{msg}")
end

bootmode=true
debug=false

OptionParser.new do |opts|
    opts.banner = "ec2-boot-init: A script to provision EC2 boot instances."

    opts.on("-u", "--update", "only updates ec2 variables values") do |v|
        bootmode=false
    end
    
    opts.on("-d", "--debug", "Run in debug mode") do |v|
        debug=true
    end
end.parse!

if debug
   log "bootmode:#{bootmode}"
   log "debug:#{debug}"
end

config = EC2Boot::Config.new

ud = EC2Boot::UserData.new(config)
md = EC2Boot::MetaData.new(config)

EC2Boot::Util.write_facts(ud, md, config)
log "Facts written."

if bootmode
    log "Boot mode enabled." if debug
    config.actions.run_actions(ud, md, config)
    log "Action run."
end

EC2Boot::Util.update_motd(ud, md, config)  if ud.fetched? && md.fetched?
log "Motd updated."
