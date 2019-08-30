#!/usr/bin/env bash
if [ $# -ne 2 ];
then
  echo "Too few arguments ... same player shoots again!"
  echo "Usage $0 number_of_cycles  number_of_keys"
  exit 1
fi
for (( cycle=1; cycle <= $1; cycle++))
do
  for (( key=1; key <= $2 ;key++))
  do
    effective_message_number=$(( ($cycle-1)* $2 + $key))
    echo "$key,This is message number#$effective_message_number"
  done
	sleep 1
done
