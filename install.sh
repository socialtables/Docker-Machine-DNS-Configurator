#!/bin/sh 
# Docker-Machine DNS setup script for OSX - installs and configures dnsmasq 
# to route 'dockerhost' DNS requests to the active docker-machine's ip

# optparse dump to globals
parse_opts() {
	local OPTIND=1
	while getopts "v" opt; do
		case $opt in
			v)
				ECHO_LOG=1
				;;
			'?')
				echo "Usage: setup.sh [-v verbose]"
				exit
				;;
		esac
	done
}

log() {
	if [ $ECHO_LOG = 1 ]; then
		echo $1
	fi
}

#############################
### execution begins here ###
#############################

ECHO_LOG=0
parse_opts $@

if [ -z $(brew list | grep dnsmasq) ]; then
	log "installing dnsmasq via homebrew..."
	brew install dnsmasq
else
	log "detected extant dnsmasq installation..."
fi

# install dnsmasq launch daemon
log "installing and starting dnsmasq launch daemon..."
echo "This next bit does some heavy lifting with sudo, standby to authenticate."
sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

# start dnsmasq
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

# add resolver for .docker domains which points to localhost
log "configuring DNS resolver for .docker domains..."
sudo mkdir -p /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/docker'

# install and start the daemon
log "installing and starting dnsmasq/docker-machine config daemon..."
sudo mkdir -p /opt/socialtables
sudo mkdir -p /opt/socialtables/docker-util
sudo cp update-docker-machine-dns.sh /opt/socialtables/docker-util/
sudo cp com.socialtables.docker-hostname-daemon.plist /Library/LaunchDaemons/
launchctl load /Library/LaunchDaemons/com.socialtables.docker-hostname-daemon.plist

log "done - your docker machine's IP should resolve at default.dockerv shortly!"
