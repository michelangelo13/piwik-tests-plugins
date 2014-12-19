cd piwik/tests/PHPUnit
echo "" > result.log

# don't want to run the 3rd party plugin's tests, just core tests & core plugin tests
rm -r ../../plugins/$TEST_PLUGIN_NAME/tests ../../plugins/$TEST_PLUGIN_NAME/Test

export TEST_SUITE=UnitTests
../travis/travis.sh 2>&1 | tee -a result.log
BREAKS_BUILD_UNIT_TESTS=${PIPESTATUS[0]}

export TEST_SUITE=IntegrationTests
../travis/travis.sh 2>&1 | tee -a result.log
BREAKS_BUILD_INTEGRATION_TESTS=${PIPESTATUS[0]}

export TEST_SUITE=SystemTests
../travis/travis.sh 2>&1 | tee -a result.log
BREAKS_BUILD_SYSTEM_TESTS=${PIPESTATUS[0]}

cat result.log | grep "in /home/travis/" | grep "on line" | grep -v "Notice"
HAS_FATAL=$?

if [ 0 == $HAS_FATAL ]; then
   echo "FATAL";
   curl "http://plugins.piwik.org/post-tests-hook/$TEST_PIWIK_VERISON/$TEST_PLUGIN_NAME/$TEST_PLUGIN_VERSION/fatal?secret=$API_HOOK_SECRET&travisBuildId=$TRAVIS_BUILD_ID"
   exit 1;
elif [ 0 == $BREAKS_BUILD_UNIT_TESTS ] && [ 0 == $BREAKS_BUILD_INTEGRATION_TESTS ] && [ 0 == $BREAKS_BUILD_SYSTEM_TESTS ]; then
   echo "SUCCESS"
   curl "http://plugins.piwik.org/post-tests-hook/$TEST_PIWIK_VERISON/$TEST_PLUGIN_NAME/$TEST_PLUGIN_VERSION/success?secret=$API_HOOK_SECRET&travisBuildId=$TRAVIS_BUILD_ID"
   exit 0;
else
   echo "FAILURE";
   curl "http://plugins.piwik.org/post-tests-hook/$TEST_PIWIK_VERISON/$TEST_PLUGIN_NAME/$TEST_PLUGIN_VERSION/failure?secret=$API_HOOK_SECRET&travisBuildId=$TRAVIS_BUILD_ID"
   exit 1;
fi

exit 1;
