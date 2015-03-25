#!/bin/bash

if [ "$BUILD_TYPE" = "PhpTests" ]; then
    ./run_php_tests.sh
elif [ "$BUILD_TYPE" = "CodeQualityTest" ]; then
    ./run_code_quality_test.sh
fi