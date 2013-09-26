cd piwik/tests/PHPUnit
./travis.sh 2>&1 | tee result.log
BREAKS_BUILD=${PIPESTATUS[0]}

cat result.log | grep "an unexpected response"
HAS_FATAL=$?

if [ 0 == $HAS_FATAL ]; then
   echo "FATAL";
   curl "http://plugins.piwik.org/post-tests-hook/$TEST_PIWIK_VERISON/$TEST_PLUGIN_NAME/$TEST_PLUGIN_VERSION/fatal?secret=$API_HOOK_SECRET"
   exit 1;
elif [ 0 == $BREAKS_BUILD ]; then
   echo "SUCCESS"
   curl "http://plugins.piwik.org/post-tests-hook/$TEST_PIWIK_VERISON/$TEST_PLUGIN_NAME/$TEST_PLUGIN_VERSION/success?secret=$API_HOOK_SECRET"
   exit 0;
else
   echo "FAILURE";
   curl "http://plugins.piwik.org/post-tests-hook/$TEST_PIWIK_VERISON/$TEST_PLUGIN_NAME/$TEST_PLUGIN_VERSION/failure?secret="$API_HOOK_SECRET"
   exit 1;
fi