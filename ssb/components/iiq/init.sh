# make iiq software available by making symbolic link to location where binaries are already available
cd $(dirname $0)
if [[ ! -e base ]]; then
    ln -s /osshare/software/sailpoint/base base
else
    echo "link already created"
fi
ls -l base 
