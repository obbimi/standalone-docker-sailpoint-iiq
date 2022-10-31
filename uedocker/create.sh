#!/bin/bash
#
# Drops any existing volumes and recreates the whole environment...
#
# Scripts run via source because the execute permissions may not be set
#

set -o pipefail
function onFailure {
    echo "###############################"
    echo "#### Unexpected failure in command - review logs above"
    exit 99
}

WINPTY_BIN="$(which winpty)"

echo "#### Build Docker Containers"
docker-compose build || onFailure

echo "#### Stop Docker"
docker-compose down -v || onFailure

echo "#### Clean logs"
rm -f volumes/app-logs/*.log* || onFailure
rm -f volumes/app-logs/*.txt || onFailure
rm -f volumes/web-logs/*.log || onFailure

echo "#### Start DB container"
docker-compose up -d db || onFailure

echo "#### Run DB Script"
DB_CONTAINER_ID=$(docker-compose ps -q db)
${WINPTY_BIN} docker exec -it --user root ${DB_CONTAINER_ID} bash -c 'source /ue/iiq/scripts/iiq-createDb.sh' || onFailure

echo "#### Start All containers"
docker-compose up -d || onFailure

APP_CONTAINER_ID=$(docker-compose ps -q app)
echo "#### Run extendedSchema"
${WINPTY_BIN} docker exec -it --user root ${APP_CONTAINER_ID} bash -c 'source /ue/iiq/scripts/iiq-extendedSchema.sh' || onFailure

# modify the script './volumes/app-ue/WEB-INF/database/add_identityiq_extensions.mysql' to use smaller columns
sed -i 's~add extended\(1[6-9]\|2[0-9]\) varchar.[0-9]*.~add extended\1 varchar(24)~' ./volumes/app-ue/WEB-INF/database/add_identityiq_extensions.mysql

echo "#### Run DB Script (again, now to 'extend' the tables with additional columns)"
${WINPTY_BIN} docker exec -it --user root ${DB_CONTAINER_ID} bash -c 'source /ue/iiq/scripts/iiq-createDb.sh' || onFailure

echo "#### Run config import"
${WINPTY_BIN} docker exec -it --user root ${APP_CONTAINER_ID} bash -c 'source /ue/iiq/scripts/iiq-loadXml.sh create' || onFailure
