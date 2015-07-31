# INSTALL BASE PACKAGES
sudo apt-get -y update
sudo apt-get -y -qq upgrade
sudo apt-get -y -qq install bash curl git build-essential bison openssl vim wget libx11-dev libx11-doc libxcb1-dev python-virtualenv
#sudo apt-get -y install --reinstall language-pack-en
export LANG="en_US.UTF-8"
git config --global url."https://".insteadOf git://

# INSTALL_CHEF
TMP_DIRECTORY=/tmp/vm-prepare
mkdir -p $TMP_DIRECTORY
cp ./standard_solo.json $TMP_DIRECTORY
cd $TMP_DIRECTORY
curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -v 11.16.2-1

# PREP_CHEF
mkdir -p $TMP_DIRECTORY/assets/cache
cat > $TMP_DIRECTORY/assets/solo.rb <<EOF
root = File.expand_path(File.dirname(__FILE__))
file_cache_path File.join(root, "cache")
cookbook_path [ "/tmp/vm-prepare/travis-cookbooks/ci_environment" ]
log_location STDOUT
verbose_logging false
EOF

rm -rf travis-cookbooks
curl -L https://api.github.com/repos/travis-ci/travis-cookbooks/tarball/28a024a6e45d04ae495ebc8fe7a1cffc12f45c8b > travis-cookbooks.tar.gz
tar xvf travis-cookbooks.tar.gz
mv travis-ci-travis-cookbooks-* travis-cookbooks

sudo chef-solo -c $TMP_DIRECTORY/assets/solo.rb -j standard_solo.json

