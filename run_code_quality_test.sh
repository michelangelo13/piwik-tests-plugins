#!/bin/bash

# travis execution helpers
source "$PIWIK_ROOT_DIR/tests/travis/travis-helper.sh"

# download phpstorm
wget -q "https://www.dropbox.com/s/w9naqsmgmul1gua/PhpStorm-8.0.3.tar.gz?dl=0" -O PhpStorm.tar.gz > /dev/null
tar -xvf PhpStorm.tar.gz > /dev/null

cd PhpStorm*

# install phpstorm license file contents
mkdir -p $HOME/.WebIde80/config
cp ../phpstorm.key $HOME/.WebIde80/config/phpstorm80.key

# install PiwikStorm plugin
git clone -q https://github.com/piwik/phpstorm-plugin-piwikstorm.git piwikstorm --depth=1 > /dev/null

# TODO: should probably build the plugin, however that might require Intellij IDEA...

mkdir -p $HOME/.WebIde80/config/plugins
wget -q "https://github.com/piwik/phpstorm-plugin-piwikstorm/releases/download/0.0.3/PiwikStorm.jar" -O $HOME/.WebIde80/config/plugins/PiwikStorm.jar > /dev/null

# add Idea project files to checkout piwik
cp -R ../travis/resources/piwik.idea "$PIWIK_ROOT_DIR/.idea"

# copy phpstorm vmoptions to phpstorm bin
cp ../travis/resources/phpstorm/phpstorm64.vmoptions ./bin/phpstorm64.vmoptions

# run inspections
cd piwikstorm/misc/runner

composer install &> /dev/null

# TODO: should use unprotected artifacts if .travis.yml of plugin contains UNPROTECTED_ARTIFACTS=1
travis_wait php ./main.php inspections:run --piwik-path="$PIWIK_ROOT_DIR" --phpstorm-path="../../../" "$TEST_PLUGIN_NAME" --artifacts-pass="$ARTIFACTS_PASS" --upload-artifacts="$TRAVIS_JOB_NUMBER"