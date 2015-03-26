#!/bin/bash

# travis execution helpers
source "$PIWIK_ROOT_DIR/tests/travis/travis-helper.sh"

# get piwikstorm source code for the runner app
git clone -q https://github.com/piwik/phpstorm-plugin-piwikstorm.git piwikstorm --depth=1 > /dev/null

# setup runner app
cd piwikstorm/misc/runner
composer install &> /dev/null

# TODO: should use unprotected artifacts if .travis.yml of plugin contains UNPROTECTED_ARTIFACTS=1

# setup phpstorm
travis_wait php ./main.php inspections:setup-phpstorm --piwik-path="$PIWIK_ROOT_DIR" --phpstorm-output-path="./phpstorm" --phpstorm-license-file="$TRAVIS_BUILD_DIR/phpstorm.key"

# run inspections
travis_wait php ./main.php inspections:run --piwik-path="$PIWIK_ROOT_DIR" --phpstorm-path="./phpstorm" "$TEST_PLUGIN_NAME" --artifacts-pass="$ARTIFACTS_PASS" --upload-artifacts="$TRAVIS_JOB_NUMBER"