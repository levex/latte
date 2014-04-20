#!/bin/bash

source ./config

_KERNEL=$2
_TEST=$1

_TEST_CONFIG="$_TEST.cfg"

if [ -e $_TEST_CONFIG ] 
then
	source ./$_TEST_CONFIG
fi

# create kernel opts
KERNEL_OPTS=${KERNEL_BASE_OPTS[*]}
echo Kernel command line: $KERNEL_OPTS

LOG_LOC="result/${TEST_NAME}.`date ${LOGFORMAT}`.dmesg"
echo $LOG_LOC

touch $LOG_LOC

# Now we have the test specific configuration if any
# let's copy the test to the initrd

cp $_TEST initrd/test

# generate the initrd
sh ./gen_initrd.sh
INITRD_ERR=$?
if [ $INITRD_ERR != 0 ]
then
	echo "FATAL: error $INITRD_ERR in generate initrd"
	exit $INITRD_ERR
fi

# and start QEMU
$QEMU ${QEMU_OPTS[*]}                  \
 -kernel $_KERNEL                      \
 -initrd "bin/initrd.igz"              \
 -append "$KERNEL_OPTS"                \
 -serial file:$LOG_LOC &

_QEMU_PID=$!

# Now wait for init message, but set a timeout
echo "QEMU started. Waiting for messages."
wait $_QEMU_PID

# kernel offline parse the result
echo "LOG: $LOG_LOC"

TEST_STATUS=0

while read line
do
	if [[ $line == *TEST_FAILURE* ]]
	then
		TEST_STATUS=1
	fi
done < "$LOG_LOC"

exit $TEST_STATUS
