#!/bin/bash
# Extracts data from a logfile produced by runexperiments.sh

LOGFILE=$1

if [[ -z $1 ]]; then
  echo "usage: $0 <logfile>"
  exit 1
fi

if [[ ! -e $LOGFILE ]]; then
  echo "error: no such file '$LOGFILE'"
  exit 1
fi

cat $LOGFILE | 
grep -E "Running|milliseconds" | 
sed -e 's/Elapsed (wall clock) time (milliseconds)://g' | 
sed -e 's/^[[:blank:]]*//;s/[[:blank:]]*//' | 
sed -e 's/^## Running \(.*\) 50 times$/\1/' |
while read line; do 
	if [[ $line =~ ^-?[0-9]+$ ]]; then
		echo -n "$line,"
	else
		echo -e -n "\n$line,"
	fi
done 
echo ""

