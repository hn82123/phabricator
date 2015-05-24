#!/bin/sh
# Wait for database to get available

MYSQL_LOOPS="50"

#wait for mysql
i=0
while ! nc $MYSQL_PORT_3306_TCP_ADDR $MYSQL_PORT_3306_TCP_PORT >/dev/null 2>&1 < /dev/null; do
  i=`expr $i + 1`
  if [ $i -ge $MYSQL_LOOPS ]; then
    echo "$(date) - $MYSQL_PORT still not reachable, giving up"
    exit 1
  fi
  echo "$(date) - waiting for $MYSQL_PORT ..."
  sleep 1
done

echo "connected"
#continue with further steps

