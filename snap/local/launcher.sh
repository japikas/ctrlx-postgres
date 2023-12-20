#!/bin/bash


#DB_PATH=$SNAP_DATA/solutions/activeConfiguration/postgres
DB_PATH=$SNAP_COMMON
DB_DATA=$DB_PATH/data
#BIN_PATH=$SNAP/usr/local/pgsql/bin
BIN_PATH=$SNAP/usr/lib/postgresql/14/bin

LD_LIBRARY_PATH=$SNAP/usr/lib/aarch64-linux-gnu:$SNAP/usr/lib/postgresql/14/lib/

#LD_LIBRARY_PATH=$SNAP/usr/lib/aarch64-linux-gnu:$NAP/usr/local/pgsql/lib

echo "Hello World!"
ls -l $SNAP

UNPRIVILEDGED="$SNAP/usr/bin/setpriv --clear-groups --reuid snap_daemon --regid snap_daemon"
#UNPRIVILEDGED="$SNAP/usr/bin/setpriv --reuid snap_daemon"

# chekc if active-solution is ready
#while ! snapctl is-connected active-solution
#do
#    echo "active-solution not ready yet, sleep."
#    sleep 5
#done
#echo "active-solution ready, proceeding"


if [ ! -d $DB_PATH ]
then
    mkdir $DB_PATH    
fi

if [ ! -d $DB_PATH/data ]
then
    mkdir $DB_PATH/data
fi

if [ ! -d $DB_PATH/log ]
then
    mkdir $DB_PATH/log
fi

if [ ! -d $DB_PATH/tmp ]
then
    mkdir $DB_PATH/tmp
fi

$SNAP/change_group.sh
#$UNPRIVILEDGED -- $SNAP/change_group.sh

echo "Database location $DB_DATA"

if [ ! -e $DB_PATH/data/PG_VERSION ]
then
    echo "Initializing database"
    $UNPRIVILEDGED -- $BIN_PATH/initdb -D $SNAP_COMMON/data -X $SNAP_COMMON/log $@
fi

# dirty hack as config file is not available via Solutions app.
echo "Change socket directory"
OLDDIR="#unix_socket_directories .*"
NEWDIR="unix_socket_directories "
$UNPRIVILEDGED -- sed -i "s@$OLDDIR@$NEWDIR@g" $SNAP_COMMON/data/postgresql.conf

OLDDIR="unix_socket_directories .*"
NEWDIR="unix_socket_directories = '/var/snap/postgres/common/tmp'"
$UNPRIVILEDGED -- sed -i "s@$OLDDIR@$NEWDIR@g" $SNAP_COMMON/data/postgresql.conf

echo "Start server"

$UNPRIVILEDGED -- $BIN_PATH/pg_ctl -D $SNAP_COMMON/data -l $SNAP_COMMON/log/postgres.log start "$@"

#echo "Exam data"
#$UNPRIVILEDGED -- $SNAP/exam.sh

echo "$SNAP_COMMON/log/postgres.log:"
$UNPRIVILEDGED -- cat $SNAP_COMMON/log/postgres.log 
$UNPRIVILEDGED -- rm $SNAP_COMMON/log/postgres.log

echo "configure database for chirpstack"
$UNPRIVILEDGED -- $BIN_PATH/psql -h 127.0.0.1 -U snap_daemon postgres -f $SNAP/chirpstack.configure

echo "Tutti finito"
exit 0
