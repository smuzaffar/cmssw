#!/bin/tcsh

eval `scram runtime -csh`

set rawLHC = L1RePack
set rawSIM = DigiL1Raw

echo
date +%F\ %a\ %T
echo Starting $0 $1 $2

set JOBS=$3
if ( "$JOBS" == "" ) then
  #By default run 4 jobs in parallel
  set JOBS=4
endif

if ( $2 == "" ) then
  set tables = ( GRun )
else if ( ($2 == all) || ($2 == ALL) ) then
  set tables = ( GRun HIon PIon PRef 2023v12 Fake Fake1 Fake2 )
else if ( ($2 == ib) || ($2 == IB) ) then
  set tables = ( GRun HIon PIon PRef )
else if ( ($2 == dev) || ($2 == DEV) ) then
  set tables = ( GRun HIon PIon PRef )
else if ( ($2 == full) || ($2 == FULL) ) then
  set tables = ( FULL )
else if ( ($2 == fake) || ($2 == FAKE) ) then
  set tables = ( Fake Fake1 Fake2 )
else if ( ($2 == frozen) || ($2 == FROZEN) ) then
  set tables = ( 2023v12 )
else
  set tables = ( $2 )
endif

foreach gtag ( $1 )

  foreach table ( $tables )

    if ($gtag == DATA) then
      set realData = True
      set base = RelVal_${rawLHC}
    else
      set realData = False
      set base = RelVal_${rawSIM}
    endif

#   run workflows

    set base = ( $base OnLine_HLT RelVal_HLT RelVal_HLT2 )

    foreach task ( $base )

      echo
      set name = ${task}_${table}_${gtag}
      rm -f $name.{log,root}

      #wait if more than ${JOBS} jobs are already running
      jobs >& bg_jobs
      while ( `cat bg_jobs |wc -l; rm -f bg_jobs` > $JOBS )
        sleep 1
        jobs >& bg_jobs
      end

      if ( $task == OnLine_HLT ) then
        set short = ${task}_${table}
        echo "`date +%T` cmsRun $short.py realData=${realData} globalTag="@" inputFiles="@" >& $name.log"
#       ls -l        $short.py
        time  cmsRun $short.py realData=${realData} globalTag="@" inputFiles="@" >& $name.log &
        echo "`date +%T` exit status: $?"
      else
        echo "`date +%T` cmsRun $name.py >& $name.log"
#       ls -l        $name.py
        time  cmsRun $name.py >& $name.log &
        echo "`date +%T` exit status: $?"
      endif

      if ( ( $task == RelVal_${rawLHC} ) || ( $task == RelVal_${rawSIM} ) ) then
#       link to input file for subsequent steps
        rm -f              RelVal_Raw_${table}_${gtag}.root
        ln -s ${name}.root RelVal_Raw_${table}_${gtag}.root
      endif

    end

  end

end

#wait for all jobs to finish
wait

# separate hlt+reco and reco+(validation)+dqm workflows

foreach gtag ( $1 )

  foreach table ( $tables )

    if ($gtag == DATA) then
      set base = ( RelVal_HLT_Reco                     RelVal_RECO )
    else
      set base = ( RelVal_HLT_Reco RelVal_DigiL1RawHLT RelVal_RECO )
    endif

    foreach task ( $base )

      #wait if more than ${JOBS} jobs are already running
      jobs >& bg_jobs
      while ( `cat bg_jobs |wc -l; rm -f bg_jobs` > $JOBS )
        sleep 1
        jobs >& bg_jobs
      end

      echo
      set name = ${task}_${table}_${gtag}
      rm -f $name.{log,root}
      echo "`date +%T` cmsRun $name.py >& $name.log"
#     ls -l        $name.py
      time  cmsRun $name.py >& $name.log &
      echo "`date +%T` exit status: $?"

    end

  end

end

#wait for all jobs to finish
wait

# running each HLT trigger path individually one by one

if ( ($2 != all) && ($2 != ib) && ($2 != dev) && ($2 != full) && ($2 != fake) && ($2 != frozen) ) then
  ./runIntegration.csh $1 $2 ${JOBS}
endif

echo
echo Finished $0 $1 $2
date +%F\ %a\ %T
#
