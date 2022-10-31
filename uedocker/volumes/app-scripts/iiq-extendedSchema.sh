#!/bin/bash
#
# This script functions from within GitBash
#
# Note: Ensure your OpenSSL is working correctly and finds the config file!
#

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

SCRIPT_FULLPATH=$(realpath "${BASH_SOURCE[0]}")
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")
SCRIPT_NAME=$(basename "$SCRIPT_FULLPATH")
IIQ_FOLDER=$(realpath "${SCRIPT_DIR}"/..)

SP_HOME="${SP_HOME:-/ue/iiq/tomcat/webapps/ue}"
LOG_FOLDER="/ue/logs/tomcat"
BACKUP_FOLDER="/ue/backups"
BACKUP_FILE="${BACKUP_FOLDER}/$(basename $SCRIPT_FULLPATH)-$(date +%Y-%m-%d-%H.%M.%S).xml"

if [ ! -f "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" ]; then
    echo "#### No permissions on IIQ - Aborting"
    exit 98
fi

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### ERROR: Unexpected failure in command - review logs above"
    exit 99
}

export LOGFILE="${LOG_FOLDER}/$(basename $SCRIPT_FULLPATH)-$(date +%Y-%m-%d-%H.%M.%S).log"
if [ ! -d "$(dirname ${LOGFILE})" ]; then
    echo "Log path not found: $(dirname ${LOGFILE})"
    exit 96
fi

# For all commands from here on, redirects stdout and stderr to tee
exec > >(tee -a "${LOGFILE}") 2>&1

function onExit {
    echo "#### `date`"
    echo "#### Log File: ${LOGFILE}"
    echo "###############################"
}
trap onExit EXIT

echo "###############################"
echo "#### Creating sql files for extending the schema"
echo "###############################"

if [ ! -x "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" ]; then
    echo "#### Setting execute permissions on iiq"
    chmod +x "${IIQ_FOLDER}/tomcat/webapps/ue/WEB-INF/bin/iiq" || onFailure
fi

runuser -s /bin/bash -c "JAVA_HOME=${IIQ_FOLDER}/java ${SP_HOME}/WEB-INF/bin/iiq extendedSchema" || onFailure
printf "\n"
