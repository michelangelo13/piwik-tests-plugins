cd piwik/tests/PHPUnit
./travis.sh 2>&1 | tee result.log
BREAKS_BUILD=${PIPESTATUS[0]}

cat result.log | grep "an unexpected response"
HAS_FATAL=$?

if [ 0 == $HAS_FATAL ]; then
   echo "FATAL";
   curl http://plugins.piwik/post-tests-hook/2.0.0/Evil/1.0.1/fatal?secret="$API_HOOK_SECRET"
   exit 1;
elif [ 0 == $BREAKS_BUILD ]; then
   echo "SUCCESS"
   curl http://plugins.piwik/post-tests-hook/2.0.0/Evil/1.0.1/success?secret="$API_HOOK_SECRET"
   exit 0;
else
   echo "FAILURE";
   curl http://plugins.piwik/post-tests-hook/2.0.0/Evil/1.0.1/failure?secret="$API_HOOK_SECRET"
   exit 1;
fi