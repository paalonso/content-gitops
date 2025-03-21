#!/bin/bash

# Desc: Script to run a patch precheck of DBCS databases running in a same Oracle Home
# Author: pablo.alonso@oracle.com (TCE - Cloud Ops Architecture)
# Vers: 1.0
# Args:
# $1: DB Home id (in dbcli format) OR db home path
# $2: OCID of the target custom DB software image
VERSION=1.0

usage() {
echo "$0 version ${VERSION}
USAGE: $0 <db home> <OCID target sw image>
        where:
          1: dbhome id in dbcli output format OR dbhome path
          2: OCID of the target sw image"
exit 1
}

if [[ $# -lt 2 ]]
then
        usage
fi

echo "Patch precheck over dbmhome $1 with custom sw image with OCID $2"
jobId=`/opt/oracle/dcs/bin/dbcli update-dbhome --dbhomeid $1 --cloneOcid $2 --precheck --json | grep jobId | awk -F\" '{print $4}'`
echo "Patch precheck jobID: $jobId"

# Monitor patch precheck job
echo "Monitoring patch precheck job status"
while true
do
        status=`/opt/oracle/dcs/bin/dbcli describe-job --jobid $jobId | grep "Status:" | awk '{print $2}'`
        if [[ "$status" == "Success" ]]
        then
                echo "Patch precheck completed successfully"
                exit 0
        elif [[ "$status" == "Failure" ]]
        then
                echo "Patch precheck failed. Review logs"
                exit -1
        elif [[ "$status" == "SuccessWithWarning" ]]
        then
                echo "Patch precheck completed successfully with warnings"
                exit 1
        fi
        sleep 60
done

exit 0
