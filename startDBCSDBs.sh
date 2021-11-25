#!/bin/bash

# Desc: Script to start DBCS databases running in a same Oracle Home
# Author: pablo.alonso@oracle.com (TCE - Cloud Ops Architecture)
# Vers: 1.0
# Args:
# $1: DB Home id (in dbcli format) OR db home path
VERSION=1.0
finished=false

usage() {
echo "$0 version ${VERSION}
USAGE: $0 <db home>
   	where db home can be:
 	  dbhome id in dbcli output format
	  dbhome path"
exit 1
}

if [[ $# -lt 1 ]]
then
	usage
fi

databases=`/opt/oracle/dcs/bin/dbcli list-databases | grep -v Running | grep $1 | awk '{print $1}'`
dbnum=`echo $databases | wc -w`

# Send start database operation (w/ dbcli)
for i in $databases
do
	echo "Starting DB $i"
	/opt/oracle/dcs/bin/dbcli start-database --dbid $i > /dev/null
done

# Monitor databases stopping and exit when done
echo "Monitoring DB running state"
while true
do
	pending=`/opt/oracle/dcs/bin/dbcli list-databases | grep $1 | awk '{print $9}' | grep -v Running | wc -l`
	echo "Start pending: $pending"
	if [[ $pending  -eq 0 ]]
	then
		echo "All databases are running"
		break
	fi
	sleep 60
done

exit 0
