#!/bin/bash

#sed on Linux and OS X have different command line options
case `uname` in Darwin) SED_OPT="-i '' -E";;*) SED_OPT="-i -r";; esac ;

pushd $LOCAL_TMP_DIR

status=0
  
rm -f u1d_errors.log u1d_warnings.log u1d_infos.log u1d_debugs.log u1d_default.log u1d_job_report.mxml 

cmsRun -j u1d_job_report.mxml -p $LOCAL_TEST_DIR/u1d_cfg.py || exit $?
 
for file in u1d_errors.log u1d_warnings.log u1d_infos.log u1d_debugs.log u1d_default.log u1d_job_report.mxml   
do
  sed $SED_OPT -f $LOCAL_TEST_DIR/filter-timestamps.sed $file
  diff $LOCAL_TEST_DIR/unit_test_outputs/$file $LOCAL_TMP_DIR/$file  
  if [ $? -ne 0 ]  
  then
    echo The above discrepancies concern $file 
    status=1
  fi
done

popd

exit $status
