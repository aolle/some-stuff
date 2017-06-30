#!/bin/bash

## remote jstatd

egcode=1
cmddebug=
cmdport=


die () {
    echo "${0}: ${2}" >&2
    exit ${1}
}

getports() {
    $(ss -l -p -n | grep ${1} | sed '0,/.*:::\([0-9]\+\).*/s//\1/')
}

if [ -z ${JAVA_HOME} ]; then
 die ${egcode} "set JAVA_HOME first"
fi

# arguments are optional
while test $# -gt 0; do
    case "${1}" in
        -p)
           shift
           # permit dynamic binding request port
           [[ ${1} =~ ^-?[0-9]+$ ]] && [[ ${1} < 65535 ]] || die ${egcode} "Incorrect port number: ${1}"
           cmdport="-p ${1}"
           ;;
        -debug)
           cmddebg="-J-Djava.rmi.server.logCalls=true"
           ;;
        *)
           die ${egcode} "Invalid arguments: $*"
           ;;
     esac
     shift
done           

echo "Choose the bind IP address:"
ifconfig | awk -v RS="\n\n" '{ for (i=1; i<=NF; i++) if ($i == "inet" && $(i+1) ~ /^addr:/) address = substr($(i+1), 6); if (address != "127.0.0.1") printf "%s\t%s\n", $1, address }'
echo -n "IP: "
read bip
           
tmpfile=$(mktemp)

cat <<- 'EOF' > ${tmpfile}
	grant codebase "file:${java.home}/../lib/tools.jar" {
	permission java.security.AllPermission;
	};
	EOF

${JAVA_HOME}/bin/jstatd ${cmdport} ${cmddebg} -J-Djava.security.policy="${tmpfile}" -J-Djava.net.preferIPv4Stack=true -J-Djava.rmi.server.hostname=${bip} &
ppid=$!
echo "Process started with PID ${ppid}."
sleep 2
rm --preserve-root -r "${tmpfile}"
