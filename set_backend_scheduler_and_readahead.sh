#!/bin/bash
for sched in /sys/class/block/sd*/queue/scheduler; do  echo "deadline" > $sched; done 
for dev in /dev/sd*; do blockdev --setra 4096 $dev; done
