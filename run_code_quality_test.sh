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

echo ""
echo "Running code inspection..."
echo ""

# run inspections
cd piwikstorm/misc
mkdir output

travis_wait `pwd`/run_inspect.sh "`pwd`/../../" "$PIWIK_ROOT_DIR" "$TEST_PLUGIN_NAME" &> ./phpstorm.out # NOTE: `pwd` is important, inspect.sh requires absolute paths
INSPECTION_RC=$?

echo ""
echo ""

if [ "$(ls -A ./output)" ]; then
    # print inspections in sort of pretty format
    php "$TRAVIS_BUILD_DIR/travis/print_inspection_output.php"

    # upload inspections as artifacts
    echo ""
    echo "Uploading inspection output..."
    echo ""

    cp phpstorm.out ./output

    url_base="http://builds-artifacts.piwik.org/upload.php?auth_key=$ARTIFACTS_PASS&build_id=$TRAVIS_JOB_NUMBER&branch=inspections.$TEST_PLUGIN_NAME.$TEST_PLUGIN_VERSION"
    if [ "$UNPROTECTED_ARTIFACTS" = "" ];
    then
        url_base="$url_base&protected=1"
        using_protected=1
    fi

    tar -cjf inspections.tar.bz2 output --exclude='.gitkeep'
    curl -X POST --data-binary @inspections.tar.bz2 "$url_base&artifact_name=inspections"

    if [ "$(ls -A ./output/PiwikNonApiInspection.xml ./output/PhpDeprecationInspection.xml ./output/PhpUndefinedMethodInspection.xml )" ]; then
        exit 1
    fi
else
    echo "No output found, inspections pass!"
fi