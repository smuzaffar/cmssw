#!/bin/tcsh

eval `scram runtime -csh`
set JOBS=$2
if ( "$JOBS" == "" ) then
  #By default run 4 jobs in parallel
  set JOBS=4
endif

echo
date +%F\ %a\ %T
echo
echo "Existing cfg files:"
ls -l OnLine*.py

echo
echo "Creating offline cfg files with cmsDriver"
echo "./cmsDriver.csh "$1
time  ./cmsDriver.csh $1

echo
date +%F\ %a\ %T
echo
echo "Running selected cfg files from:"
pwd

time ./runOne.csh DATA    $1 ${JOBS} >& ./runOne-DATA.log
time ./runOne.csh MC      $1 ${JOBS} >& ./runOne-MC.log

echo
echo "Resulting log files:"
ls -l *.log
echo
date +%F\ %a\ %T
