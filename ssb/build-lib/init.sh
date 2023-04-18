cd $(dirname $0)

zipfile=apache-ant-1.10.10-bin.zip 
if [[ ! -e ${zipfile} ]]; then
    wget https://github.com/UberEther/standalone-docker-sailpoint-iiq/raw/master/ssb/build-lib/${zipfile}
else
    echo "apache ant file already downloaded: ${zipfile}"
fi

