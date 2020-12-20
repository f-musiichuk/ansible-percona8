#!/usr/bin/env bash

# $1 Container's name
# $2 mysql user
# $3 mysql pass,
# $4 Master host
# $5 master user for replication
# $6 master pass for replication
# $7 database
# $8 root pass

sleep 5
# add replicate to master

docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
            -e"CREATE USER IF NOT EXISTS '$5'@'%' IDENTIFIED BY '$6'; "

docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
            -e"CREATE DATABASE IF NOT EXISTS $7;"

docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
            -e"GRANT ALL ON \`$7\`.* TO '$5'@'%' ;"

docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
            -e"FLUSH PRIVILEGES ;"


docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
            -e"STOP SLAVE; "

docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
    -e"CHANGE MASTER TO
       MASTER_HOST='$4',
       MASTER_USER='$5',
       MASTER_PASSWORD='$6',
       MASTER_AUTO_POSITION = 1; "

docker exec -ti $1 'mysql' \
            -uroot -p$8 -vvv \
            -e"START SLAVE; "

