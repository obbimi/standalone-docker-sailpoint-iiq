clientname=${1:-AGInsurance}
clientconfigdir=${2:-/export/code/uprightsecurity/identityiq}

cd $(dirname $0)
cp -v ../local-dev/*iiq.properties sandbox.iiq.properties
(
echo iiq
echo ssb-v7
echo $clientname
) >> components.txt


mkdir ../../components/$clientname
ln -s ${clientconfigdir}/config           ../../components/$clientname/.
ln -s ${clientconfigdir}/web              ../../components/$clientname/.


ln -s  ${clientconfigdir}/sandbox.target.properties  .



# there has to be a build.properies file with at least the versions to use
cat ${clientconfigdir}/build.properties | grep -E '^IIQ' | grep -Evi '^IIQHOME' | tee -a build.properties

