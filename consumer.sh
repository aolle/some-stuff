#!/bin/bash

# Àngel Ollé Blázquez
# disk consumption script

tmpfile1=$(mktemp /tmp/XXXXXX)
tmpfile2=$(mktemp /tmp/XXXXXX)
tmpfile3=$(mktemp /tmp/XXXXXX)
tmpfile4=$(mktemp /tmp/XXXXXX)

#exec 6>"$tmpfile1"
#exec 7>"$tmpfile2"
trap "{ rm -f $tmpfile1 $tmpfile2 $tmpfile3 $tmpfile4; }" EXIT

#rm "$tmpfile1" "$tmpfile2"

echo "files: $tmpfile1 , $tmpfile2, $tmpfile3, $tmpfile4"

# some boilerplate code

while : ; do dd if=/dev/zero of=${tmpfile1} bs=1M count=1024 oflag=direct ; done &
pid1=$!

while : ; do dd if=/dev/zero of=${tmpfile2} bs=1M count=1024 oflag=direct ; done &
pid2=$!

while : ; do dd if=/dev/zero of=${tmpfile3} bs=1M count=1024 oflag=direct ; done &
pid3=$!

while : ; do dd if=/dev/zero of=${tmpfile4} bs=1M count=1024 oflag=direct ; done &
pid4=$!

echo "press any key to exit"
read

kill $pid1 $pid2 $pid3 $pid4
wait $pid1
wait $pid2
wait $pid3
wait $pid4

