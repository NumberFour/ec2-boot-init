#!/usr/bin/ruby

require 'ec2boot'
localmode=false

def log(msg)
    puts "#{Time.now}> #{msg}"
    system("logger", "#{msg}")
end

# "parse" command line
ARGV.each {|arg| 
  localmode=true if arg == "local"
}

if localmode
    log "Local mode enabled"
    config = EC2Boot::LocalConfig.new

    ud = EC2Boot::UserData.new(config)
    md = EC2Boot::MetaData.new(config, { 
                                   "ami_id" => "ami-123", 
                                   "instance_type" => "i-456", 
                                   "placement_availability_zone" => "zone-abc", 
                                   "hostname" => "examplehost.exampledomain", 
                                   "public_hostname" => "dns.aws.com" 
                               })
else
    puts "Network mode enabled"
    config = EC2Boot::Config.new

    ud = EC2Boot::UserData.new(config)
    md = EC2Boot::MetaData.new(config)
end


EC2Boot::Util.write_facts(ud, md, config)
log "Facts written."

config.actions.run_actions(ud, md, config)
log "Action run."

EC2Boot::Util.update_motd(ud, md, config)  if ud.fetched? && md.fetched?
log "Motd updated."
