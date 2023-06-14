clientname=${1:-AGInsurance}
clientconfigdir=${2:-/osshare/code/uprightsecurity/identityiq}

cd $(dirname $0)
cp -v ../local-dev/*iiq.properties sandbox.iiq.properties
(
echo iiq
echo ssb-v7
echo $clientname
) >> components.txt

if [[ ! -e ../../components/$clientname ]]; then
    mkdir ../../components/$clientname
    ln -s ${clientconfigdir}/config           ../../components/$clientname/.
    ln -s ${clientconfigdir}/web              ../../components/$clientname/.
else
    echo "Already exists: $PWD/../../components/$clientname"
fi
ls -l ../../components/$clientname

if [[ ! -e sandbox.target.properties ]]; then
    ln -s ${clientconfigdir}/sandbox.target.properties .
fi



# there has to be a build.properies file with at least the versions to use
cat ${clientconfigdir}/*build.properties | grep -E '^IIQ' | grep -Evi '^IIQHOME' | sort -u | tee -a build.properties

