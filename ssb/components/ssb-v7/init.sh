cd $(dirname $0)

zipfile=ssb-v7.zip
if [[ ! -e ${zipfile} ]]; then
    ln -s /osshare/software/sailpoint/ssd/${zipfile} ${zipfile}
else
    echo "Symbolic link already created ${zipfile}"
fi
ls -l ${zipfile}

