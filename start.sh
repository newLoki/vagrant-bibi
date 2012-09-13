git submodule init
git submodule update
pushd Sites/bibi
php `pwd`/../../composer.phar update
popd
vagrant up
vagrant ssh