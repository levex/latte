#!/bin/bash

source ./config

echo "Welcome to to LATTE - Linux Automatic Testing Tool for Experts"

echo "Kernel that we will work on: $1"
__KERNEL=$1

echo "Tests that will be run:"

echo "${TESTS[*]}"

TEST_RESULTS=()
testno=0

read -p "Start testing (y/n)? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	for TEST in "${TESTS[@]}"
	do
		sh start_kernel.sh tests/$TEST $__KERNEL
		if [[ $? == 0 ]]
		then
			echo "$TEST was successful"
			TEST_RESULTS[$testno]=0
			testno=$testno+1
			continue
		fi
		echo "$TEST was NOT successful"
		TEST_RESULTS[$testno]=1
		testno=$testno+1
		continue
	done
	# make results nice
	echo "-------------------------[cut here]-----------------------------------"
	i=0
	for TEST in "${TESTS[@]}"
	do
		if [[ ${TEST_RESULTS[$i]} == 0 ]]
		then
			echo "PASS: $TEST"
			i=$i+1
			continue
		fi
		echo "*****FAIL****: $TEST"
		i=$i+1
		continue
	done
	echo "-------------------------[cut here]-----------------------------------"
	exit 0
fi

echo "ABORTED"
exit 1
