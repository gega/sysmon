#!/bin/bash

POLL_INTERVAL_SEC=60

(
  flock -n -e 200 || exit;

  echo $$ >/tmp/sysmon.pid
  CONF=/etc/sysmon.conf
  TAG="sysmon.sh"

  N=$(cat $CONF|jq -r .[].name|wc -l)

  for((i=0;i<N;i++)) do
    NAME[$i]=$(cat $CONF|jq -r .[$i].name)
    RUN[$i]=$(cat $CONF|jq -r .[$i].run)
    CHECK[$i]=$(cat $CONF|jq -r .[$i].check)
    if [ "${CHECK[$i]}" == "null" ]; then
      CHECK[$i]="cat /proc/\$(cat /tmp/sm_${NAME[$i]}.pid 2>/dev/null)/statm &>/dev/null"
    fi
  done

  while [ true ]; 
  do
    for((i=0;i<N;i++)) do
      bash -c "${CHECK[$i]}"
      if [ $? -ne 0 ]; then
        ( bash -c "${RUN[$i]}" ) &
        PID=$!
        echo $PID >/tmp/sm_${NAME[$i]}.pid
        logger -p local0.notice -t $TAG "${NAME[$i]} restarted [$PID]"
      fi
    done
    sleep $POLL_INTERVAL_SEC
  done
) 200>/tmp/sysmon.sh.lock &
