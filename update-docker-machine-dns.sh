#!/bin/sh 
# Social Tables docker DNS configurator for OSX - updates dnsmask's configuration
# to point the specified hostname at the specified docker machine's IP address

# help blob
show_help() {
	echo "Usage: update-docker-machine-dns [ -h hostname ] [ -m machine name ] [ -d (daemon mode) ]"
}

# optparse dump to globals
parse_opts() {
	local OPTIND=1
	while getopts "dh:m:?" opt; do
		case $opt in
			h)
				HOST_NAME="$OPTARG"
				;;
			m)
				MACHINE_NAME="$OPTARG"
				;;
			d)
				IS_DAEMON=1
				;;
			'?')
				show_help
				exit
				;;
		esac
	done
}

# adds or modifies a simple config file line
upsert_config_line() {
	
	local TAG=$1
	local VAL=$2
	local TARGET_FILE=$3
	local FOUND_CONFIG_LINE=$(grep "${TAG}" ${TARGET_FILE})
	
	if [ -z $FOUND_CONFIG_LINE ]; then

		# strip escape slashes and insert into file
		echo "${VAL} # ${TAG}" | sed -E 's/\\(.)/\1/g' >> ${TARGET_FILE}
	else

		# replace extant line in file
		sed -i .old "s/.* # ${TAG}/${VAL} # ${TAG}/" ${TARGET_FILE}
	fi
}

# updates a docker machine dnsmasq DNS entry
update_docker_machine_entry() {

	local MACHINE_NAME="${1:-default}"
	local HOST_NAME="${2:-${MACHINE_NAME}.docker}"
	local MACHINE_IP="$(docker-machine ip ${MACHINE_NAME})"

	if [ -z $MACHINE_IP ]; then
		echo "Unable to resolve docker machine IP"
		return
	fi

	# update dnsmasq config
	upsert_config_line "DOCKER MACHINE HOST <${HOST_NAME}>" "address=\\/${HOST_NAME}\\/${MACHINE_IP}" $(brew --prefix)/etc/dnsmasq.conf
}

#############################
### execution begins here ###
#############################

# parse command line options
parse_opts $@

# assign defaults
if [ -z $MACHINE_NAME ]; then
	MACHINE_NAME="default"
fi
if [ -z $HOST_NAME ]; then
	HOST_NAME="${MACHINE_NAME}.docker"
fi

# ensure dnsmasq config file exists
mkdir -pv $(brew --prefix)/etc/
touch $(brew --prefix)/etc/dnsmasq.conf

# normal mode - invoke once
if [ -z $IS_DAEMON ]; then
	update_docker_machine_entry $MACHINE_NAME $HOST_NAME

# daemon mode - invoke once every two minutes
else
	while true; do
		update_docker_machine_entry $MACHINE_NAME $HOST_NAME
		sleep 120
	done
fi
